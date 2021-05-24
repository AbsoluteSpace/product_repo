module Messages
    MESSAGES = {
      discounts: {
        percent_too_large: "Percent discount must be at most 100.",
      },
      products: {
          discount: {
            exceeds_price: "must be less than price.",
            not_present: "must be present if this product has an active discount.",
          },
      },
      tags: {
          invalid: "Tags must be a comma seperated list with only alphanumeric characters and whitespace."
      }
    }.freeze
end