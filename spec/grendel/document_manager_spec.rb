require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "Grendel::DocumentManager" do
  before do
    @client = Grendel::Client.new("http://grendel")
    @user_id = "alice"
    @password = "s3kret"
    @user = Grendel::User.new(@client, :id => @user_id, :password => @password)
    @base_uri = "#{@user_id}:#{@password}@grendel/users/#{@user_id}/documents"
  end

  describe "list" do
    before do
      stub_json_request(:get, @base_uri, %{{
          "documents":[
            {"name":"document1.txt",
             "uri":"http://grendel/users/#{@user_id}/documents/document1.txt"},
            {"name":"document2.txt",
             "uri":"http://grendel/users/#{@user_id}/documents/document2.txt"}
          ]}})
    end

    it "should return an array of all documents" do
      docs = @user.documents.list
      docs.length.should == 2
      docs[0].name.should == "document1.txt"
      docs[0].uri.should == "/users/#{@user_id}/documents/document1.txt"
      docs[1].name.should == "document2.txt"
      docs[1].uri.should == "/users/#{@user_id}/documents/document2.txt"
    end
  end

  describe "find" do
    before do
      stub_json_request(:get, @base_uri + "/document1.txt", "yay for me", :content_type => "text/plain")
      stub_json_request(:get, @base_uri + "/notfound.txt", "", :status => [404, "Not Found"])
    end

    it "should return the document" do
      doc = @user.documents.find("document1.txt")
      doc.name.should == "document1.txt"
      doc.content_type.should == "text/plain"
      doc.data.should == "yay for me"
    end

    it "should raise an exception if the document is not found" do
      lambda {
        @user.documents.find("notfound.txt")
      }.should raise_error(Grendel::Client::HTTPException) {|error| error.message.should == "404 Not Found"}
    end
  end

  describe "store" do
    describe "a successful request" do
      before do
        stub_json_request(:put, @base_uri + "/new_document.txt", "", :status => [204, "No Content"])
      end

      it "should send a properly-formatted request" do
        @user.documents.store("new_document.txt", "top secret stuff", "text/plain")
        params = { "id" => @user_id, "password" => @password }
        request(:put, @base_uri + "/new_document.txt").
          with(:body => "top secret stuff", :headers => {"Content-Type" => "text/plain"}).
          should have_been_made.once
      end

      it "should guess the content type if not provided" do
        @user.documents.store("new_document.txt", "top secret stuff")
        params = { "id" => @user_id, "password" => @password }
        request(:put, @base_uri + "/new_document.txt").
          with(:body => "top secret stuff", :headers => {"Content-Type" => "text/plain"}).
          should have_been_made.once
      end

      it "should default the content type to 'application/octet-stream' if unknown" do
        stub_json_request(:put, @base_uri + "/new_document.-wtf-", "", :status => [204, "No Content"])
        @user.documents.store("new_document.-wtf-", "top secret stuff")
        params = { "id" => @user_id, "password" => @password }
        request(:put, @base_uri + "/new_document.-wtf-").
          with(:body => "top secret stuff", :headers => {"Content-Type" => "application/octet-stream"}).
          should have_been_made.once
      end

      it "should return a document" do
        doc = @user.documents.store("new_document.txt", "top secret stuff")
        doc.name.should == "new_document.txt"
        doc.data.should == "top secret stuff"
        doc.content_type.should == "text/plain"
      end
    end
  end

  describe "delete" do
    before do
      stub_json_request(:delete, @base_uri + "/document.txt", "", :status => [204, "No Content"])
      @document = Grendel::Document.new(@user, :name => "document.txt")
    end

    it "should send a properly-formatted request" do
      @user.documents.delete("document.txt")
      request(:delete, @base_uri + "/document.txt").should have_been_made.once
    end
  end
end
