### WARNING: Using this service costs money!!!

# Service object for translating text using the Google Translate API
class GoogleTranslator

  require 'net/http'
  require 'uri'
  require 'json'

  BASE_URL = "https://translation.googleapis.com/language/translate/v2"
  
  attr_accessor :target_lang, :source_lang

  def initialize(api_key, opts={})
    @url = "#{BASE_URL}?key=#{api_key}"
    @locales_url = "#{BASE_URL}/languages?key=#{api_key}"
    Rails.logger.info(@url)
    @target_lang = opts[:target] || opts[:target_lang] || opts[:to] || "es"
    @source_lang = opts[:source] || opts[:source_lang] || opts[:from] || "en"
  end

  # Sets the source language, and returns self so method can be chained
  def from(lang)
    @source_lang = lang
    return self
  end
  
  # Sets the target language, and returns self so method can be chained
  def to(lang)
    @target_lang = lang
    return self
  end

  # Translates the given string q from the source language to the target language
  def translate q, target=@target_lang, source=@source_lang
    
    # Pull out any interpolate variables contained in braces {}, and save them
    interpolated_vars = []
    q = q.to_s.gsub(/{[^{}]*?}/) do |var|
      interpolated_vars << var
      next "{}"
    end
    
    # Build a google translate API params hash
    params = {
	    "q": q,
	    "source": source,
	    "target": target,
      "format": "text"
    }
    
    # Get the translation from the google API, and re-insert the interpolated variables
    response = self.send(params)
    self.unpack(response).gsub(/{[^{}]*?}/) { |var| interpolated_vars.shift }
  end

  def locales target=@target_lang, locales_url=@locales_url
    # Build a google translate API params hash
    params = {
        "target": target,
        "format": "text"
    }

    # Get the languages from the google API
    response = self.send(params,@locales_url)
    if response.code == '200'
      begin
        return JSON.parse(response.body)["data"]['languages']
      rescue JSON::ParserError
        return []
      end
    else
      return []
    end
  end
  
 	## Send the Requests
  def send(params,url=@url)
    uri = URI.parse(url)
    header = {'Content-Type': 'text/json'}
    # Create the HTTP objects
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(uri.request_uri, header)
    request.body = params.to_json

    return http.request(request)
  end #send

  # Get the Actual Translations
  def unpack(response)

    if response.code == '200'
      begin
        return JSON.parse(response.body)["data"]["translations"].first["translatedText"]  || ""
      rescue JSON::ParserError
        return ""
      end
    else
      return ""
    end

  end
	
end
