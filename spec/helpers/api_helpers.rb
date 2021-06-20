module ApiHelpers
  def post_with_json(uri, data)
    json = JSON.generate(data)
    headers = {"CONTENT_TYPE" => "application/json"}
    post(uri, json, headers)
  end

  def post_with_xml(uri, data)
    xml = data.stringify_keys.map { |k, v| [k, v.is_a?(Symbol) ? String(v) : v] }.to_h.to_xml
    headers = {"CONTENT_TYPE" => "application/xml"}
    post(uri, xml, headers)
  end

  def json_response
    JSON.parse(last_response.body)
  end

  def xml_response
    xml = Hash.from_xml(last_response.body)
    xml.dig("hash") || xml.dig("objects")
  end
end
