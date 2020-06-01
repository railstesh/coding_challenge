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

  def create_keys(json, lang = 'en')
    resp = client.create_keys(project_id, keys_params(json, lang))
    keys_arr = generate_keys(json).keys
    key_id_info(resp, keys_arr)
  end

  def keys_params(json lang = 'en')
    generate_keys(json).map do |k, v|
      { "key_name": k, "platforms": ["ios", "android", "web", "other"], "translations": [{ "language_iso": lang, "translation": v }] }
    end
  end

  def key_id_info(response, arr)
    kinfo = {}
    response.collection.each_with_index do |coll, i|
      data = coll.raw_data
      kinfo[arr[i]] = data['key_id']
    end
    kinfo
  end

  def key(id)
    retry_count = 0
    begin
      client.key(project_id, id)
    rescue Lokalise::Error::Locked => e
      retry_count += 1
      retry if retry_count < 5

      puts "Rescued: #{e.inspect}"
    end
  end

  def translation(key_id, lang = 'en')
    key = key(key_id)
    translations = key.translations.select { |t| t['language_iso'].eql?(lang) }
    return unless translations.present?

    translations.first['translation']
  end
end
