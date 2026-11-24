class Product < ApplicationRecord
  has_many :line_items, dependent: :restrict_with_error
  has_many :carts, through: :line_items
  belongs_to :category, optional: true, counter_cache: true

  after_initialize :set_default_title
  before_validation :set_discount_price, on: :create
  # before_destroy :ensure_not_referenced_by_any_line_item
  scope :enabled, -> { where(enabled: true) }
  after_save :product_count_on_save, if: :saved_change_to_category_id?
  after_destroy :product_count_on_destroy

  has_one_attached :image
  after_commit -> { broadcast_refresh_later_to "products" }
  validates :title, :description, :image, presence: true
  validates :title, uniqueness: true
  validates :permalink, uniqueness: true
  validates :permalink, format: { with: /\A[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+){2,}\z/ }
  validate :acceptable_image
  validate :description_word_count
  # validate :discount_price_less_than_price
  validates :discount_price,
    comparison: { less_than_or_equal_to: :price },
    if: -> { discount_price.present? && price.present? }

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG or PNG image")
    end
  end
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }

  def self.products_in_atleast_one_line_item
    joins(:line_items).distinct
  end

  def self.title_of_products_in_atleast_one_line_item
    joins(:line_items).distinct.pluck(:title)
  end
  def self.titles_using_associated
    where.associated(:line_items).distinct.pluck(:title)
  end

  def description_word_count
    return if description.blank?

    word_count = description.split.size

    unless word_count.between?(5, 10)
      errors.add(:description, "must contain between 5 and 10 words")
    end
  end

  def discount_price_less_than_price
    return if discount_price.blank? || price.blank?

    if discount_price >= price
      errors.add(:discount_price, "must be less than the original price")
    end
  end

  private

  # ensure that there are no line items referencing this product
  def ensure_not_referenced_by_any_line_item
    unless line_items.empty?
      errors.add(:base, "Line Items present")
      throw :abort
    end
  end

  def set_default_title
    self.title ||= "abc"
  end

  def set_discount_price
    self.discount_price ||= price
  end

  def increment_product_count(category_id)
    parent_category = Category.find_by(id: category_id)&.parent
    parent_category.increment!(:products_count) if parent_category
  end

  def decrement_product_count(category_id)
    parent_category = Category.find_by(id: category_id)&.parent
    parent_category.decrement!(:products_count) if parent_category
  end

  def product_count_on_save
    if category_id_previously_was != category_id
      decrement_product_count(category_id_previously_was) if category_id_previously_was
      increment_product_count(category_id) if category_id
    end
  end

  def product_count_on_destroy
    decrement_product_count(category_id) if category_id
  end
end
