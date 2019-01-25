require 'active_support/core_ext/string/output_safety'

module BreachMitigation
  class LengthHiding
    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)

      # Only pad HTML/XHTML documents, and only on HTTPS connections
      if headers['Content-Type'] =~ /text\/x?html/ && ssl?(env) && !looks_like_a_file?(body)
        # Copy the existing response to a new object
        response = Rack::Response.new(body, status, headers)

        # Append to that response
        response.write random_html_comment

        body.close if body.respond_to? :close
        response.finish
      else
        [status, headers, body]
      end
    end

    private

    def ssl?(env)
      request = Rack::Request.new(env)
      if request.respond_to? :ssl?
        request.ssl?
      else
        # There is no Rack::Request#ssl? on Rack 1.1, so we do the check ourselves
        request.scheme == 'https'
      end
    end

    def looks_like_a_file?(body)
      body.respond_to?(:to_path)
    end

    # Append a comment from 0 to MAX_LENGTH bytes in size to the
    # response body. See section 3.1 of "BREACH: Reviving the CRIME
    # attack". This should make BREACH attacks take longer, but does
    # not fully protect against them. The longer MAX_LENGTH is, the
    # more effective the mitigation is, however longer lengths mean
    # more time spent in this middleware and more data on the wire.

    MAX_LENGTH = 2048
    ALPHABET = ('a'..'z').to_a

    def random_html_comment
      # The length of the padding should be strongly random, but the
      # data itself doesn't need to be strongly random; it just needs
      # to be resistant to compression
      length = SecureRandom.random_number(MAX_LENGTH)
      junk = (0...length).inject('', &method(:generate_junk))

      "\n<!-- This is a random-length HTML comment: #{junk} -->".html_safe
    end

    def generate_junk(junk, *args)
      # While Ruby 1.9's `Enumerable#inject` yields only the object, Ruby 1.8
      # also passes each item from the list as a 2nd argument.
      # We only want to modify the given object, and ignore any extra arguments.
      junk << ALPHABET[rand(ALPHABET.size)]
    end
  end
end
