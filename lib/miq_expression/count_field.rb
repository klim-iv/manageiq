class MiqExpression::CountField < MiqExpression::Target
  REGEX = /
(?<model_name>([[:upper:]][[:alnum:]]*(::)?)+)
\.(?<associations>[a-z_\.]+)
/x

  def self.parse(field)
    parsed_params = parse_params(field) || return
    count_field = new(parsed_params[:model_name], parsed_params[:associations])

    is_plural = suppress(Exception) { count_field.plural? }
    return unless is_plural

    count_field
  end

  def initialize(model, associations)
    super(model, associations, nil)
  end

  def to_s
    [model, *associations].join(".")
  end

  def column_type
    :integer
  end

  def attribute_supported_by_sql?
    reflection_supported_by_sql?
  rescue ArgumentError
    # the association chain is not legal, so no, it is not supported by sql
    false
  end

  private

  def tag_values
    ['virtual'] + @associations
  end
end
