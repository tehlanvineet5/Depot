class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    unless value.match?(URI::DEFAULT_PARSER.make_regexp(%w[http https]))
      record.errors.add(attribute, "must be a valid URL")
    end
  end
end
