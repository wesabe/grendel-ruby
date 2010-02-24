module Grendel
  class LinkManager

    def initialize(document)
       @document = document
       @base_uri = @document.uri + "/links"
    end

    # return links to this document
    def list
      response = @document.user.get(@base_uri)
      response["links"].map do |link| 
        Link.new(@document, User.new(@document.user.client, link["user"]), :uri => link["uri"])
      end
    end
    
    # add a link to a user and return a Link object
    def add(user_id)
      # REVIEW: 2010-02-23 <brad@wesabe.com> -- what does Grendel return if the link already exists?
      @document.user.put(@base_uri + "/" + user_id)
      Link.new(@document, User.new(@document.user.client, :id => user_id))
    end

    # remove a link to a user
    def remove(user_id)
      # REVIEW: 2010-02-23 <brad@wesabe.com> -- what does Grendel return if the link didn't exist?
      @document.user.delete(@base_uri + "/" + user_id)
    end
  end
end