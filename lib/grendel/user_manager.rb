module Grendel
  class UserManager
    
    def initialize(client)
      @client = client
    end

    # return all Grendel users as Grendel::User objects    
    def list
      response = @client.get("/users")
      response["users"].map {|u| User.new(@client, u) }
    end
    
    # retrieve a user, optionally setting the password
    def find(id, password = nil)
      response = @client.get("/users/#{id}") # need to escape this
      user = User.new(@client, response)
      user.password = password
      return user
    end
    
    # create a new user
    def create(id, password)
      params = {:id => id, :password => password}
      response = @client.post("/users", params)
      # TODO: strip protocol and host from uri
      User.new(@client, params.merge(:uri => response.headers['location'].first))
    end
    
  end
end