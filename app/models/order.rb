class Order < ApplicationRecord

  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :shipping_address, presence: true
  validates :phone, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def completed?
    status == 'completed'
  end

end
