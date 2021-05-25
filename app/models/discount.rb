class Discount < ApplicationRecord
    has_many :products
    
    validates :name, presence: true, uniqueness: true
    validates_inclusion_of :percent_discount, in: [true, false]
    validates :discount, presence: true, numericality: { greater_than: 0 }
    validate :percent_discount_is_at_most_100
    validate :tags_are_correct_format
    validates_inclusion_of :all_tags, in: [true, false]
    validates_inclusion_of :active, in: [true, false]

    before_destroy :deactive_discount

    paginates_per 10

    def update_site_discounts
        Product.find_each do |product|
            next unless product.can_be_discounted

            unless self.active
                remove_discount(product)
                next
            end

            if !product.discount.nil? && product.discount.id == self.id
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

    def deactive_discount
        update_attribute(:active, false)
        update_site_discounts
    end

    def remove_discount(product)
        return if product.discount.nil? || (product.discount.id != self.id && !self.all_tags)

        product.remove_cur_discount

        product.apply_largest_discount
    end

    def percent_discount_is_at_most_100
        return unless percent_discount

        if !discount.nil? && discount > 100
            errors.add(:discount, Messages::MESSAGES[:discounts][:percent_too_large])
        end
    end

    def tags_are_correct_format
        return if tags.nil?

        unless Tags.new(tags).valid?
            errors.add(:tags, Messages::MESSAGES[:tags][:invalid])
            return 
        end
    end
end
