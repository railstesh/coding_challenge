require 'open-uri'

class GithubService
  attr_reader :username, :repo

  def initialize(username, repo)
    @username = username
    @repo = repo
  end

  def read_file(tool_name, language, branch = 'master')
    file_name = "#{tool_name.upcase}.#{language}.master.json"

    retry_count = 0
    begin
      raw_link = "https://raw.githubusercontent.com/#{username}/#{repo}/#{branch}/#{file_name}"
      web_contents = open(raw_link, &:read)
      JSON.parse(web_contents)
    rescue OpenURI::HTTPError => e
      if e.io.status[0].to_i == 404
        retry_count += 1
        file_name.sub!('.master', '')
        retry if retry_count < 2
        nil
      end
    end
  end

  # if you face any problem in pushing, add your ssh to gitHub
  def create_push_branch(branch)
    `git checkout -b #{branch}`
    # in case the branch already present
    `git checkout #{branch}`

    file_name = branch.sub(/.*-\d*-/, '')
    `git add #{file_name}`

    `git commit -m 'Update translation'`

    `git push origin #{branch}`

    `git checkout master`
  end

  def create_pr(branch)
    options = { 'title': branch,
                'body': 'Please pull these updated translation changes in!',
                'head': branch, 'base': 'master' }
    HTTParty.post(
      "https://api.github.com/repos/#{username}/#{repo}/pulls",
      basic_auth: { username: username,
                    password: Rails.application.credentials.git_hub[:password] },
      body: options.to_json
    )
  end
end
