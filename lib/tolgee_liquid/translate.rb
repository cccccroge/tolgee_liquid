require 'net/http'
require 'message_format'

class Translate
  def initialize
    @tolgee_api_url = TolgeeLiquid.configuration.api_url
    @tolgee_api_key = TolgeeLiquid.configuration.api_key
    @tolgee_project_id = TolgeeLiquid.configuration.project_id
  end

  def execute(name, vars = {}, opts)
    locale = opts[:locale]
    dev_mode = opts[:mode] == 'development'
    static_data = opts[:static_data]
    dict = dev_mode ? get_remote_dict(locale.to_s) : static_data[locale.to_sym]
    value = fetch_translation(dict, name)
    return name if value.nil?

    translation = MessageFormat.new(value, locale.to_s).format(vars.transform_keys(&:to_sym))

    if dev_mode
      message = { k: name }.to_json
      hidden_message = ZeroWidthCharacterEncoder.new.execute(message)
      "#{translation}#{hidden_message}"
    else
      translation
    end
  end

  def fetch_translation(dict, name)
    name.split('.'.freeze).reduce(dict) do |level, cur|
      return nil if level[cur].nil?

      level[cur]
    end
  end

  def get_remote_dict(locale)
    @remote_dict ||= begin
      url = URI("#{@tolgee_api_url}/v2/projects/#{@tolgee_project_id}/translations/#{locale}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'application/json'
      request['X-API-Key'] = @tolgee_api_key

      response = http.request(request)
      JSON.parse(response.body)[locale]
    rescue
      {}
    end
  end
end
