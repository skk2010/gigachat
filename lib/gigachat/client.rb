module GigaChat
  class Client
    include GigaChat::HTTP

    CONFIG_KEYS = %i[
      api_type
      api_version
      client_base64
      log_errors
      uri_base
      uri_auth
      request_timeout
      extra_headers
    ].freeze
    attr_reader *CONFIG_KEYS, :faraday_middleware

    def initialize(config = {}, &faraday_middleware)
      CONFIG_KEYS.each do |key|
        # Set instance variables like client_id. Fall back to global config
        # if not present.
        instance_variable_set(
          "@#{key}",
          config[key].nil? ? GigaChat.configuration.send(key) : config[key]
        )
      end
      @faraday_middleware = faraday_middleware
    end

    def models
      @models ||= GigaChat::Models.new(client: self)
    end

    def chat(parameters: {})
      json_post(path: "/chat/completions", parameters: parameters)
    end

    def embeddings(parameters: {})
      json_post(path: "/embeddings", parameters: parameters)
    end

  end
end
