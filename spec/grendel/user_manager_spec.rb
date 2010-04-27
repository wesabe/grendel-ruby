require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Grendel::User" do
  before do
    @client = Grendel::Client.new("http://grendel")
  end

  describe "list" do
    before do
      stub_json_request(:get, "grendel/users", %{{
        "users":[
          {"id":"alice", "uri":"http://grendel/users/alice"},
          {"id":"bob",   "uri":"http://grendel/users/bob"}
        ]
      }})
    end

    it "should return an array of all users" do
      users = @client.users.list
      users.length.should == 2
      users[0].id.should == "alice"
      users[0].uri.should == "/users/alice"
      users[1].id.should == "bob"
      users[1].uri.should ==  "/users/bob"
    end
  end

  describe "find" do
    before do
      stub_json_request(:get, "grendel/users/alice", %{{
        "id":"alice",
        "modified-at":"20091227T211121Z",
        "created-at":"20091227T211120Z",
        "keys":['2048-RSA/0A895A19', '2048-RSA/39D1621B']
      }})
      stub_json_request(:get, "grendel/users/nobody", "", :status => [404, "Not Found"])
    end

    it "should return the user" do
      user = @client.users.find("alice")
      user.id.should == "alice"
      user.modified_at.should == DateTime.parse("20091227T211121Z")
      user.created_at.should == DateTime.parse("20091227T211120Z")
      user.keys.length.should == 2
    end

    it "should raise an exception if the user is not found" do
      lambda {
        @client.users.find("nobody")
      }.should raise_error(Grendel::Client::HTTPException) {|error| error.message.should == "404 Not Found"}
    end
  end

  describe "create" do
    describe "a successful request" do
      before do
        @user_id = "bob"
        @password = "s3kret"
        @uri = "http://grendel/users/#{@user_id}"
        stub_json_request(:post, "grendel/users", "", :status => [201, "Created"], "Location" => @uri)
      end

      it "should send a properly-formatted request" do
        @client.users.create(@user_id, @password)
        params = { :id => @user_id, :password => @password }
        request(:post, "grendel/users").with(:body => params.to_json).should have_been_made.once
      end

      it "should return a user" do
        user = @client.users.create(@user_id, @password)
        user.id.should == @user_id
        user.password.should == @password
        user.uri.should == "/users/bob"
      end
    end

    describe "an unsuccessful request" do
      before do
        stub_json_request(:post, "grendel/users", "", :status => [422, "Unprocessable Entity"])
      end

      it "should raise an exception if the user already exists" do
        lambda {
          @client.users.create("joe","exists")
        }.should raise_error(Grendel::Client::HTTPException) {|error| error.message.should == "422 Unprocessable Entity"}
      end
    end
  end
end
