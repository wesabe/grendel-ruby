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
      options.merge!(:debug_output => @debug_output) if @debug
      response = HTTParty.get(@base_uri + uri, options)
      raise HTTPException.new(response) if response.code >= 400
      return response
    end

    def post(uri, data = {}, options = {})
      data = data.to_json unless options.delete(:raw_data)
      options.merge!(
          :body => data,
          :headers => {'Content-Type' => 'application/json'}
      )
      options.merge!(:debug_output => @debug_output) if @debug
      response = HTTParty.post(@base_uri + uri, options)
      raise HTTPException.new(response) if response.code >= 400
      return response
    end

    def put(uri, data = {}, options = {})
      data = data.to_json unless options.delete(:raw_data)
      options = {
        :body => data,
        :headers => {'Content-Type' => 'application/json'}
      }.update(options)
      options.merge!(:debug_output => @debug_output) if @debug
      response = HTTParty.put(@base_uri + uri, options)
      raise HTTPException.new(response) if response.code >= 400
      return response
    end

    def delete(uri, options = {})
      options.merge!(:debug_output => @debug_output) if @debug
      response = HTTParty.delete(@base_uri + uri, options)
      raise HTTPException.new(response) if response.code >= 400
    end

    def users
      UserManager.new(self)
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
