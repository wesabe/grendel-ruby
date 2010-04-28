# Ruby interface to Wesabe's Grendel (http://github.com/wesabe/grendel)
module Grendel
  class Client
    attr_accessor :debug, :debug_output
    attr_reader :base_uri

    # Create a new Grendel client instance
    def initialize(base_uri, options = {})
      @base_uri = base_uri
      @debug = options[:debug]
      @debug_output = options[:debug_output] || $stderr
    end

    def get(uri, options = {})
      process_response HTTParty.get(@base_uri + uri, process_options(options))
    end

    def head(uri, options = {})
      process_response HTTParty.head(@base_uri + uri, process_options(options))
    end

    def post(uri, data = {}, options = {})
      process_response HTTParty.post(@base_uri + uri, process_options(options, data))
    end

    def put(uri, data = {}, options = {})
      process_response HTTParty.put(@base_uri + uri, process_options(options, data))
    end

    def delete(uri, options = {})
      process_response HTTParty.delete(@base_uri + uri, process_options(options))
    end

    def users
      UserManager.new(self)
    end

    private
      def process_response(response)
        raise HTTPException.new(response) if response.code >= 400
        return response
      end

      def process_options(options, data=nil)
        options = options.dup

        if data
          data = data.to_json unless options.delete(:raw_data)
          options[:body] ||= data
          options[:headers] = (options[:headers] || {}).dup
          options[:headers]['Content-Type'] ||= 'application/json'
        end

        options[:debug_output] ||= @debug_output if @debug

        return options
      end

    class HTTPException < Exception
      def initialize(response)
        msg = "#{response.code} #{response.message}"
        msg << "\n#{response.body}" unless response.body.blank?
        super(msg)
      end
    end
  end
end
