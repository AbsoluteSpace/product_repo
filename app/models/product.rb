class Product < ApplicationRecord
    belongs_to :discount, optional: true
    
    validates :title, presence: true
    validates :body, presence: true
    validates :file_location, presence: true
    validate :tags_are_correct_format
    validates :price, presence: true, numericality: { greater_than: 0 }
    validates :discount_price, numericality: { greater_than: 0 }, allow_nil: true
    validates_inclusion_of :can_be_discounted, in: [true, false]
    validates_inclusion_of :has_active_discount, in: [true, false]
    validate :discount_price_less_than_price if :has_active_discount
    validate :discount_price_present

    paginates_per 10

    def apply_largest_discount(refresh = false)
        unless self.can_be_discounted
            disable_discounts
            return
        end

        remove_cur_discount if refresh

        lowest_price, best_discount = find_best_discount

        return if best_discount.nil? || lowest_price == self.price || lowest_price <= 0

        update_discount_attributes(true, best_discount, lowest_price)
    end

    def apply_discount(discount)
        return unless self.can_be_discounted

        new_discount_price = calculate_discount_price(discount)
        current_discount_price = self.has_active_discount ? self.discount_price : self.price
        lowest_price = new_discount_price <= current_discount_price ? new_discount_price : current_discount_price

        return if lowest_price == current_discount_price || lowest_price <= 0

        update_discount_attributes(true, discount, lowest_price)
    end

    def remove_cur_discount
        update_discount_attributes(false, nil, self.price)
    end

    def disable_discounts
        self.update_attribute(:has_active_discount, false)
        self.update_attribute(:can_be_discounted, false)
        self.update_attribute(:discount, nil)
        self.update_attribute(:discount_price, self.price)
    end

    def enable_discounts
        self.update_attribute(:can_be_discounted, true)
        apply_largest_discount
    end

    def calculate_discount_price(discount)
        if discount.percent_discount
            return self.price - (discount.discount / 100)*self.price
        else
            return self.price - discount.discount
        end
    end

    private

    def discount_price_less_than_price
        if discount_price.nil? || price.nil?
            return
        end

        if discount_price > price
            errors.add(:discount_price, Messages::MESSAGES[:products][:discount][:exceeds_price])
        end
    end

    def discount_price_present
        return unless has_active_discount
        errors.add(:discount_price, Messages::MESSAGES[:products][:discount][:not_present]) if discount_price.nil?
    end

    def tags_are_correct_format
        return if tags.nil?

        unless Tags.new(tags).valid?
            errors.add(:tags, Messages::MESSAGES[:tags][:invalid])
            return 
        end
    end

    def find_best_discount
        current_discount_price = self.has_active_discount ? self.discount_price : self.price
        lowest_price = current_discount_price
        best_discount = self.has_active_discount ? self.discount : nil

        Discount.find_each do |discount|
            next unless discount.active

            if discount.all_tags
                new_discount_price = calculate_discount_price(discount)
                lowest_price = new_discount_price < lowest_price ? new_discount_price : lowest_price
                best_discount = new_discount_price == lowest_price ? discount : best_discount
                next
            end

            next if self.tags.nil?

            next if (discount.tags.split(",") & self.tags.split(",")).empty?

            new_discount_price = calculate_discount_price(discount)
            lowest_price = new_discount_price < lowest_price ? new_discount_price : lowest_price
            best_discount = new_discount_price == lowest_price ? discount : best_discount
        end

        return lowest_price, best_discount
    end

    def update_discount_attributes(has_discount, discount, lowest_price)
        self.update_attribute(:has_active_discount, has_discount)
        self.update_attribute(:discount, discount)
        self.update_attribute(:discount_price, lowest_price)
    end
end
