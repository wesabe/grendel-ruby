require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Grendel::Document" do
  before do
    @client = Grendel::Client.new("http://grendel")
    @user_id = "alice"
    @password = "s3kret"
    @user = Grendel::User.new(@client, :id => @user_id, :password => @password)
    @base_uri = "#{@user_id}:#{@password}@grendel/users/#{@user_id}/documents"
    @document = Grendel::Document.new(@user, :name => "document.txt")
  end

  describe "delete" do
    before do
      stub_json_request(:delete, @base_uri + "/document.txt", "", :status => [204, "No Content"])
    end

    it "should send a properly-formatted request" do
      @document.delete
      request(:delete, @base_uri + "/document.txt").should have_been_made.once
    end
  end

  describe "accessing content type without it being set" do
    before do
      @document.content_type = nil
      stub_request(:head, @base_uri + "/document.txt").
        to_return(:body => "", :status => 200, :headers => {"Content-Type" => "application/x-lolcat"})
    end

    it "loads content type" do
      @document.content_type.should == "application/x-lolcat"
    end

    it "causes a HEAD request for the document" do
      @document.content_type
      request(:head, @base_uri + "/document.txt").should have_been_made.once
    end
  end

  describe "accessing data without it being set" do
    before do
      @document.data = nil
      stub_request(:get, @base_uri + "/document.txt").
        to_return(:body => "OMGLOL", :status => 200, :headers => {"Content-Type" => "application/x-lolcat"})
    end

    it "loads the data" do
      @document.data.should == "OMGLOL"
    end

    it "causes a GET request for the document" do
      @document.data
      request(:get, @base_uri + "/document.txt").should have_been_made.once
    end

    it "populates the content type too" do
      @document.content_type = nil
      @document.data
      @document.content_type.should == "application/x-lolcat"
    end
  end
end
