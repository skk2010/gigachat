require "faraday"
require "faraday/multipart"

require_relative "gigachat/http"
require_relative "gigachat/models"
require_relative "gigachat/client"
require_relative "gigachat/version"

module GigaChat
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class MiddlewareErrors < Faraday::Middleware
    def call(env)
      @app.call(env)
    rescue Faraday::Error => e
      raise e unless e.response.is_a?(Hash)

      logger = Logger.new($stdout)
      logger.error(e.response[:body])

      raise e
    end
  end

  class Configuration
    attr_accessor :api_type,
                  :api_version,
                  :log_errors,
                  :client_base64,
                  :uri_base,
                  :uri_auth,
                  :request_timeout,
                  :extra_headers

    DEFAULT_API_VERSION = "v1".freeze
    DEFAULT_URI_BASE = "https://gigachat.devices.sberbank.ru/api/".freeze
    DEFAULT_AUTH_UURL = "https://ngw.devices.sberbank.ru:9443/api/v2/oauth".freeze
    DEFAULT_REQUEST_TIMEOUT = 120
    DEFAULT_LOG_ERRORS = false

    def initialize
      @api_type = nil # GIGACHAT_API_PERS, GIGACHAT_API_B2B, GIGACHAT_API_CORP
      @api_version = DEFAULT_API_VERSION
      @log_errors = DEFAULT_LOG_ERRORS
      @client_base64 = nil
      @uri_base = DEFAULT_URI_BASE
      @uri_auth = DEFAULT_AUTH_UURL
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @extra_headers = {}
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= GigaChat::Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  # Estimate the number of tokens in a string, using the rules of thumb from OpenAI:
  # https://help.openai.com/en/articles/4936856-what-are-tokens-and-how-to-count-them
  def self.rough_token_count(content = "")
    raise ArgumentError, "rough_token_count requires a string" unless content.is_a? String
    return 0 if content.empty?

    count_by_chars = content.size / 4.0
    count_by_words = content.split.size * 4.0 / 3
    estimate = ((count_by_chars + count_by_words) / 2.0).round
    [1, estimate].max
  end
end