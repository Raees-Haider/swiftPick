class Product < ApplicationRecord

  has_many :cart_items, dependent: :destroy
  has_many :order_items, dependent: :destroy
  has_many :product_categories, dependent: :destroy
  has_many :categories, through: :product_categories
  

  has_one_attached :image

  # Validations
  validates :name,
            presence: true,
            length: { minimum: 3, maximum: 100 }

  validates :description,
            presence: true,
            length: { minimum: 10 }

  validates :price,
            presence: true,
            numericality: { greater_than: 0 }

  validates :stock_quantity,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  validates :active, inclusion: { in: [true, false] }

  validates :image, presence: { message: "Please select an image file" }, if: :new_record?

  validate :at_least_one_category

  private

  def at_least_one_category
    category_ids_array = category_ids.present? ? category_ids.reject(&:blank?) : []
    if category_ids_array.empty? && categories.empty?
      errors.add(:categories, "must have at least one category selected")
    end
  end

end
