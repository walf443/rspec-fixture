module Spec::Fixture::Filter
  constants.each do |const|
    extend const
  end

  class << self
    def eval str
      eval(str.to_s)
    end

    def timep str
      require 'time'
      Time.parse(str.to_s)
    end

    def html_escape str
      require 'cgi'
      CGI.escapeHTML(str.to_s)
    end

    def html_unescape str
      require 'cgi'
      CGI.unescapeHTML(str.to_s)
    end
    
    def pathname str
      require 'pathname'
      Pathname.new(str.to_s)
    end

    def uri str
      require 'uri'
      URI.new(str.to_s)
    end

    def uri_encode str
      require 'uri'
      URI.encode(str.to_s)
    end

    def uri_decode str
      require 'uri'
      URI.decode(str.to_s)
    end

    def base64_encode str
      require 'base64'
      Base64.encode64(str.to_s)
    end

    def base64_decode str
      require 'base64'
      Base64.decode64(str.to_s)
    end
  end
end
