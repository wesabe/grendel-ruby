module Grendel
  class LinkedDocument < Document
    attr_accessor :linked_user, :owner

    # create a new linked document
    # user - linked user
    # params:
    # :name => document name
    # :uri => linked document uri
    # :owner => {
    #   :id => owner id
    #   :uri => owner uri
    # }
    def initialize(linked_user, params)
      params = Mash.new(params)
      @owner = User.new(linked_user.client, params[:owner])
      super(@owner, params)
      @linked_user = linked_user
      @name = params[:name]
      @uri = params[:uri] ?
        URI.parse(params[:uri]).path :
        ["/linked-documents", @owner.id, name].join("/")
    end

    # delete this linked document
    def delete
      @linked_user.delete(@uri)
    end
  end
end