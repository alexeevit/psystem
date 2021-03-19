class ApplicationPresenter
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def self.as_json(presenters)
    presenters.map(&:data).to_json
  end

  def self.as_xml(presenters)
    presenters.map(&:data).to_xml
  end

  def as_json
    data
  end

  def as_xml
    data.to_xml
  end
end
