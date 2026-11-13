class Product < ApplicationRecord
  has_many :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

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
    comparison: { less_than: :price },
    if: -> { discount_price.present? && price.present? }

  def acceptable_image
    return unless image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a GIF, JPG or PNG image")
    end
  end
  validates :price, numericality: { greater_than_or_equal_to: 0.01 }

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
end
