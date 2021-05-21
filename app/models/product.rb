class Product < ApplicationRecord
    validates :title, :body, :tags, :file_location, :price, :discount_price, :active_discount_name, presence: true
    validates :title, uniqueness: true
    validate :tags_are_correct_format
    validates :price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0 }
    validates :discount_price, format: { with: /\A\d+(?:\.\d{0,2})?\z/ }, numericality: { greater_than: 0 }
    validate :discount_price_less_than_price if :has_active_discount
    validates_inclusion_of :can_be_discounted, in: [true, false]
    validates_inclusion_of :has_active_discount, in: [true, false]

    def apply_discount(discount)
        return unless self.can_be_discounted

        new_discount_price = calculate_discount_price(discount)
        current_discount_price = self.has_active_discount ? self.discount_price : self.price
        lowest_price = new_discount_price <= current_discount_price ? new_discount_price : current_discount_price

        return if lowest_price == current_discount_price || lowest_price <= 0

        update_discount_attributes(true, discount.name, lowest_price)
    end

    def update_discount_attributes(has_discount, name, lowest_price)
        self.update_attribute(:has_active_discount, has_discount)
        self.update_attribute(:active_discount_name, name)
        self.update_attribute(:discount_price, lowest_price)
    end

    def calculate_discount_price(discount)
        if discount.percent_discount
            return self.price - (discount.discount / 100)*self.price
        else
            return self.price - discount.discount
        end
    end

    def disable_discounts
        self.update_attribute(:has_active_discount, false)
        self.update_attribute(:can_be_discounted, false)
        self.update_attribute(:active_discount_name, "")
        self.update_attribute(:discount_price, self.price)
    end

    def enable_discounts
        self.update_attribute(:can_be_discounted, true)
        apply_largest_discount
    end

    def apply_largest_discount
        current_discount_price = self.has_active_discount ? self.discount_price : self.price
        lowest_price = current_discount_price
        best_discount_name = self.has_active_discount ? self.active_discount_name : ""

        Discount.find_each do |discount|
            next unless discount.active

            if discount.all_tags
                new_discount_price = calculate_discount_price(discount)
                lowest_price = new_discount_price < lowest_price ? new_discount_price : lowest_price
                best_discount_name = discount.name
                next
            end

            next if self.tags.nil?

            next if (discount.tags.split(",") & self.tags.split(",")).empty?

            new_discount_price = calculate_discount_price(discount)
            lowest_price = new_discount_price < lowest_price ? new_discount_price : lowest_price
            best_discount_name = discount.name
        end

        return if lowest_price == current_discount_price || lowest_price <= 0

        update_discount_attributes(true, best_discount_name, lowest_price)
    end

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
