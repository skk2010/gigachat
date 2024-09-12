module GigaChat
  module HTTPHeaders
    def add_headers(headers)
      @extra_headers = extra_headers.merge(headers.transform_keys(&:to_s))
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Accept" => "application/json",
        "Authorization" => "Bearer #{access_token}"
      }.merge(extra_headers)
    end

    def extra_headers
      @extra_headers ||= {}
    end

    def access_token
      if @access_token.nil? || (@expires_in.to_i - Time.now.to_i).negative?
        url = URI(@uri_auth)

        https = Net::HTTP.new(url.host, url.port)
        https.use_ssl = true
        https.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = "application/x-www-form-urlencoded"
        request["Accept"] = "application/json"
        request["RqUID"] = SecureRandom.uuid
        request["Authorization"] = "Basic #{@client_base64}"
        request.body = "scope=#{@api_type}"

        resp = https.request(request).body
        json = JSON.parse(resp)
        @expires_in = json['expires_at']
        @access_token = json['access_token']
      end
      @access_token
    end
  end
end