module Chatbots
  class DomainParser < ApplicationService
    DEFAULT_SCHEME = "https://".freeze
    WWW_PREFIX_REGEX = /\Awww\./.freeze

    def initialize(url)
      @url = url.to_s.strip
    end

    def call
      return if @url.blank?

      host = parsed_url.host
      host_without_prefix = host&.sub(WWW_PREFIX_REGEX, "")

      PublicSuffix.parse(host_without_prefix)

      host_without_prefix
    rescue URI::InvalidURIError, PublicSuffix::DomainNotAllowed
      nil
    end

    private

    attr_reader :url

    def parsed_url
      URI.parse(normalized_url)
    end

    def normalized_url
      has_scheme? ? url : "#{DEFAULT_SCHEME}#{url}"
    end

    def has_scheme?
      URI.parse(url).scheme.present?
    rescue URI::InvalidURIError
      false
    end
  end
end
