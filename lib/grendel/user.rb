module Grendel
  class User
    attr_accessor :id, :password, :uri
    attr_reader :client, :modified_at, :created_at, :keys
    
    # create a new Grendel::User object
    # params:
    #  id
    #  uri
    #  password
    def initialize(client, params)
      params.symbolize_keys!
      @client = client
      @id = params[:id]
      @uri = params[:uri] ? 
        URI.parse(params[:uri]).path :
        "/users/" + @id # escape this?
      @password = params[:password]
      @modified_at = DateTime.parse(params[:"modified-at"]) if params[:"modified-at"]
      @created_at = DateTime.parse(params[:"created-at"]) if params[:"created-at"]
      @keys = params[:keys]
    end

    # return user's creds in the form required by HTTParty
    def auth
      {:basic_auth => {:username => id, :password => password}}
    end

    #
    # methods to do authenticated client calls with the user's base_uri
    #
    def get(uri = "", options = {})
      options.merge!(auth)
      @client.get(@uri + uri, options)
    end
    
    def post(uri = "", data = {}, options = {})
      options.merge!(auth)
      @client.post(@uri + uri, data, options)
    end
    
    def put(uri = "", data = {}, options = {})
      options.merge!(auth)
      @client.put(@uri + uri, data, options)
    end

    def delete(uri = "", options = {})
      options.merge!(auth)
      @client.delete(@uri + uri, options)
    end
    
    # change the user's password
    def change_password(new_password)
      put("", {:password => new_password})
      @password = new_password
    end
    
    # send documents calls to the DocumentManager
    def documents
      DocumentManager.new(self)
    end
    
    # send linked documents calls to the LinkedDocumentManager
    def linked_documents
      LinkedDocumentManager.new(self)
    end
  end
end