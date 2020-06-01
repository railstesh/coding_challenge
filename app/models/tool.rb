class Tool < ApplicationRecord
  validates :name, :language, presence: true

  def update_translation
    github = GithubService.new('railstesh', 'coding_challenge')
    lokalise = LokaliseService.new(nil, nil)
    spec_data = github.read_file(name, language)

    # handle a special key 'tool_version'
    sp_key = key_info["#{name.upcase}_tool_version"]
    if sp_key
      translation = lokalise.translation(sp_key, language)
      spec_data['tool_version'] = translation
      key_info.delete("#{name.upcase}_tool_version")
    end

    key_info.each do |key, k_id|
      translation = lokalise.translation(k_id, language)
      write_value(spec_data, key, translation)
    end

    file = File.open("#{name}.#{language}.json", 'w') do |f|
      f.write(JSON.pretty_generate(spec_data))
    end

    branch_name = "tool-#{id}-#{name}.#{language}.json"
    github.create_push_branch(branch_name)
    github.create_pr(branch_name)
  end

  private

  def write_value(hash, x_value, new_value)
    recurse(hash, x_value.sub(/^#{name}_/i, '').split('_'), new_value)
  end

  def recurse(hash, keys, new_value)
    k = keys.shift
    keys.empty? ? (hash[k] = new_value) : recurse(hash[k], keys, new_value)
  end
end
