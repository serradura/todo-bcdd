# frozen_string_literal: true

class User::Email < Kind::Value
  value_object(with: :validation) do |strategy_to|
    def strategy_to.normalize(input)
      String(input).strip.downcase
    end

    FORMAT = ::URI::MailTo::EMAIL_REGEXP

    def strategy_to.validate(value)
      'is invalid' unless value.present? && value.match?(FORMAT)
    end
  end
end
