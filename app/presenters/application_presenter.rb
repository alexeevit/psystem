class ApplicationPresenter
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def as_json
    data
  end
end
