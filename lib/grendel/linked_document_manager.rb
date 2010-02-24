module Grendel
  class LinkedDocumentManager
    def initialize(user)
      @user = user
      @base_uri = "/linked-documents"
    end
    
    # list this user's linked documents. Returns an array of LinkedDocument objects
    def list
      response = @user.get(@base_uri)
      response["linked-documents"].map {|ld| LinkedDocument.new(@user, ld) }
    end
    
    # retreive a linked document
    def find(owner_id, name)
      response = @user.get([@base_uri, owner_id, name].join("/"))
      params = {
        :name => name,
        :data => response.body,
        :content_type => response.headers['content-type'].first,
        :owner => { :id => owner_id }
      }
      LinkedDocument.new(@user, params)
    end
    
    # delete the linked document
    def delete(owner_id, name)
      @user.delete([@base_uri, owner_id, name].join("/"))
    end
  end
end