module Grendel
  class DocumentManager    

    def initialize(user)
      @user = user
      @base_uri = "/documents"
    end
    
    # list all documents
    def list
      response = @user.get(@base_uri)
      response["documents"].map {|d| Document.new(@user, d) }
    end
    
    # retreive a document
    def find(name)
      response = @user.get(@base_uri + "/" + name)
      params = {
        :name => name,
        :data => response.body,
        :content_type => response.headers['content-type'].first
      }
      Document.new(@user, params)
    end
    
    # store a document, creating a new one if it doesn't exist, or replacing the existing one if it does
    def store(name, data, content_type = nil)
      # if the content type isn't provided, guess it or set it to a default
      unless content_type
        if mime_type = MIME::Types.type_for(name).first
          content_type = mime_type.content_type
        else
          content_type = 'application/octet-stream'
        end
      end
      
      response = @user.put(@base_uri + "/" + name, data, :raw_data => true, :headers => {'Content-Type' => content_type})
      Document.new(@user, :name => name, :data => data, :content_type => content_type)
    end
    
    # delete the specified document from Grendel
    def delete(name)
      @user.delete(@base_uri + "/" + name)
    end

  end
end