require "test_helper"

class TagsTest < ActiveSupport::TestCase

    def setup
        @tags = Tags.new("tag1,tag2")
      end
    
      test "valid tags" do
        assert @tags.valid?
      end

      test "invalid tags from special characters" do
        @tags.tags = "*,tag2<,$"
        refute @tags.valid?
      end

      test "tags allow whitespace" do
        @tags.tags = "tag 1,tag 2, tag3"
        assert @tags.valid?
      end

end