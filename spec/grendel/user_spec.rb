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
    
  describe "change_password" do
    before do
      @old_password = "s3kret"
      @new_password = "newpass"
      @user = Grendel::User.new(@client, :id => "alice", :password => @old_password)
      @url = "#{@user.id}:#{@user.password}@grendel/users/#{@user.id}"
      stub_json_request(:put, @url, "", :status => "204 No Content")
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
      stub_json_request(:delete, @url, "", :status => "204 No Content")
    end
    
    it "should send a properly-formatted request" do
      @user.delete
      request(:delete, @url).should have_been_made.once
    end
  end
end
