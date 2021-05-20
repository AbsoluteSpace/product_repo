class Discount < ApplicationRecord
    validates :name, :discount, :tags, presence: true
    validates :name, uniqueness: true
    validates_inclusion_of :percent_discount, in: [true, false]
    validates :discount, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0 }
    validate :percent_discount_is_at_most_100
    validate :tags_are_correct_format
    validates_inclusion_of :all_tags, in: [true, false]
    validates_inclusion_of :active, in: [true, false]

    def update_site_discounts
        Product.find_each do |product|
            next unless product.can_be_discounted

            unless self.active
                remove_discount(product)
                next
            end

            if product.active_discount_name == self.name
                remove_discount(product) if (self.tags.split(",") & product.tags.split(",")).empty?
                next
            end

            if self.all_tags
                product.apply_discount(self) 
                next
            end

            next if product.tags.nil?

            next if (self.tags.split(",") & product.tags.split(",")).empty?

            product.apply_discount(self)
        end
    end

    private

    def remove_discount(product)
        return if product.active_discount_name.to_s != self.name && !self.all_tags

        product.update_discount_attributes(false, "", product.price)

        product.apply_largest_discount
    end

    def percent_discount_is_at_most_100
        return unless percent_discount

        if !discount.nil? && discount > 100
            errors.add(:discount, "Percent discount must be at most 100.")
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
