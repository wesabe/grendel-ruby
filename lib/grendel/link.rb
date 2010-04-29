module Grendel
  class Link
    attr_accessor :document, :user, :uri

    def initialize(document, user, params = {})
      params = Mash.new(params)
      @document = document
      @user = user
      @uri = params[:uri] ?
        URI.parse(params[:uri]).path :
        "/links/" + @user.id # escape this?
    end

  end
end