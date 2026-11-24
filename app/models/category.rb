class Category < ApplicationRecord
  belongs_to :parent, class_name: "Category", optional: true

  has_many :subcategories,
           class_name: "Category",
           foreign_key: :parent_id,
           dependent: :destroy

  has_many :products, dependent: :restrict_with_error

  has_many :subcategory_products,
           through: :subcategories,
           source: :products

  validates :name,
            presence: true,
            uniqueness: { scope: :parent_id }

  validate :prevent_nested_subcategories

  before_destroy :prevent_destroy_if_subcategory_products_exist, prepend: true

  def prevent_nested_subcategories
    return if parent_id.blank?
    return if parent.parent_id.blank?

    errors.add(:base, "cannot be a subcategory of another subcategory")
  end

  private

  def prevent_destroy_if_subcategory_products_exist
    if subcategory_products.exists?
      errors.add(:base, "Cannot delete category because subcategories have products")
      throw :abort
    end
  end
end
