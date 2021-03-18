module CommonValidations
  def validate_amount
    (errors[:amount] = ["is blank"]) && return if params[:amount].blank?

    amount = Integer(params[:amount])
    (errors[:amount] = ["is not positive"]) && return if amount <= 0
  rescue TypeError, ArgumentError
    errors[:amount] = ["has non-integer value"]
  end

  def clean_invalid_params
    errors.keys.each do |key|
      params.delete(key)
    end
  end
end
