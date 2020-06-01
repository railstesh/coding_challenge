class LokaliseService
  attr_reader :client, :project_id

  def initialize(client_id, project_id)
    client_id ||= Rails.application.credentials.client_id
    @client = Lokalise.client(client_id)
    @project_id =  project_id.presence || Rails.application.credentials.project_id
  end

  def generate_keys(json, parent = 'BMI')
    keys = {}

    json.each do |key, value|
      if value.is_a?(String)
        keys["#{parent}_#{key}"] = value
      elsif value.is_a?(Hash)
        hsh = generate_keys(value, "#{parent}_#{key}")
        keys.merge!(hsh) if hsh.values.all? { |v| v.is_a?(String) }
      end
    end
    keys.presence
  end

  def create_keys(json)
    client.create_keys(project_id, keys_params(json))
  end

  def keys_params(json)
    generate_keys(json).map do |k, v|
      { "key_name": k, "platforms": ["ios", "android", "web", "other"], "translations": [{ "language_iso": "en", "translation": v }] }
    end
  end
end
