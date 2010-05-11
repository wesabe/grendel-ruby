require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Grendel::User" do
  before do
    @client = Grendel::Client.new("http://grendel")
  end

  describe "new" do
    it "should strip the protocol and host from the uri" do
      user = Grendel::User.new(@client, :id => "alice", :uri => "http://grendel/users/alice")
      user.uri.should == "/users/alice"
    end
  end

  describe "find" do
    context "a non-existent user" do
      it "raises a HTTPException with response code 404" do
        stub_json_request(:get, 'http://grendel/users/idontexist', "", :status => [404, "Not Found"])
        begin
          @client.users.find('idontexist', 'nordoi')
          fail "HTTPException should have been raised but wasn't"
        rescue Grendel::Client::HTTPException => e
          e.response.code.should == 404
        end
      end
    end
  end

  describe "change_password" do
    before do
      @old_password = "s3kret"
      @new_password = "newpass"
      @user = Grendel::User.new(@client, :id => "alice", :password => @old_password)
      @url = "#{@user.id}:#{@user.password}@grendel/users/#{@user.id}"
      stub_json_request(:put, @url, "", :status => [204, "No Content"])
    end

    it "should send a properly-formatted request" do
      @user.change_password(@new_password)
      params = { "password" => @new_password }
      request(:put, @url).with(:body => params.to_json).should have_been_made.once
    end

    it "should return a User with the new password" do
      lambda {
        @user.change_password(@new_password)
      }.should change(@user, :password).from(@old_password).to(@new_password)
    end
  end

  describe "delete" do
    before do
      @user = Grendel::User.new(@client, :id => "alice", :password => "s3kret")
      @url = "#{@user.id}:#{@user.password}@grendel/users/#{@user.id}"
      stub_json_request(:delete, @url, "", :status => [204, "No Content"])
    end

    it "should send a properly-formatted request" do
      @user.delete
      request(:delete, @url).should have_been_made.once
    end
  end
end
