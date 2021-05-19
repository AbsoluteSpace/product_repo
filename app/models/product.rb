class Product < ApplicationRecord
    validates :title, :body, :tags, :file_location, :price, :discount_price, :active_discount_name, presence: true
    validates :title, uniqueness: true
    validate :tags_are_correct_format
    validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0 }
    validates :discount_price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0 }
    validate :discount_price_less_than_price if :has_active_discount
    validates_inclusion_of :can_be_discounted, in: [true, false]
    validates_inclusion_of :has_active_discount, in: [true, false]

    private

    def discount_price_less_than_price
        if discount_price.nil? || price.nil?
            return
        end

        if discount_price > price
            errors.add(:discount_price, "Discount price must be less than price.")
        end
    end
    
    def tags_are_correct_format
        return if tags.nil?

        if Tags.new(tags).invalid_tags?
            errors.add(:tags, "Tags must be a comma seperated list with only alphanumeric characters.")
            return 
        end
    end
end
