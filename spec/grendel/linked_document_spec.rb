require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Grendel::LinkedDocument" do
  before do
    @client = Grendel::Client.new("http://grendel")
    @user_id = "alice"
    @password = "s3kret"
    @user = Grendel::User.new(@client, :id => @user_id, :password => @password)
    @base_uri = "#{@user_id}:#{@password}@grendel/users/#{@user_id}/linked-documents"
  end

  describe "delete" do
    before do
      stub_json_request(:delete, @base_uri + "/bob/document.txt", "", :status => [204, "No Content"])
      @linked_document = Grendel::LinkedDocument.new(@user, :name => "document.txt", :owner => {:id => "bob"})
    end

    it "should send a properly-formatted request" do
      @linked_document.delete
      request(:delete, @base_uri + "/bob/document.txt").should have_been_made.once
    end
  end
end
