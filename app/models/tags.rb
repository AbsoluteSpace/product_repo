class Tags
    def initialize(tags)
        @tags = tags
    end

    def invalid_tags?
        @tags.split(",") do |tag|
            return true unless is_correct_format(tag)
        end

        return false
    end

    def is_correct_format(tag)
        tag.match?(/\A[a-zA-Z0-9]*\z/)
    end
end