class Tags
    attr_accessor :tags

    def initialize(tags)
        @tags = tags
    end

    def valid?
        @tags.split(",") do |tag|
            return false unless is_correct_format(tag)
        end

        return true
    end

    private

    def is_correct_format(tag)
        tag.match?(/\A[\sa-zA-Z0-9]*\z/)
    end
end