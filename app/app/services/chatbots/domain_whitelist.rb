module Chatbots
  class DomainWhitelist
    BLOCKED_DOMAINS = %w[google.com google.pl facebook.com linkedin.com instagram.com allegro.pl github.com youtube.com].freeze

    def self.allowed?(domain)
      BLOCKED_DOMAINS.include?(domain)
    end
  end
end
