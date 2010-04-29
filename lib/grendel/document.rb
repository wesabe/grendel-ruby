module Grendel
  class Document
    attr_accessor :user, :name, :uri, :data, :content_type

    def initialize(user, params)
      params = Mash.new(params)
      @user = user
      @client = user.client
      @name = params[:name]
      @data = params[:data]
      @content_type = params[:content_type]
      @uri = params[:uri] ?
        URI.parse(params[:uri]).path :
        "/documents/" + @name # escape this?
    end

    # delete this document from Grendel
    def delete
      @user.delete(@uri)
    end

    # send link operations to the Link class
    def links
      LinkManager.new(self)
    end

    def content_type
      @content_type ||= begin
        @user.head(@uri).headers['content-type'].first
      end
    end

    def data
      @data ||= begin
        response = @user.get(@uri)
        @content_type = response.headers['content-type'].first
        response.body
      end
    end
  end
end