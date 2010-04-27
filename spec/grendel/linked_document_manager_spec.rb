require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# - get a list of documents a user has linked to them
# docs = user.linked_documents.list
# - retrieve a linked document
# doc = user.linked_documents.find("owner_user_id", "document.txt")
# - delete a linked document
# user.linked_documents.delete("owner_user_id", "document.txt")

describe "Grendel::LinkedDocumentManager" do
  before do
    @client = Grendel::Client.new("http://grendel")
    @user_id = "alice"
    @password = "s3kret"
    @user = Grendel::User.new(@client, :id => @user_id, :password => @password)
    @document = Grendel::Document.new(@user, :name => "document1.txt")
    @base_uri = "#{@user_id}:#{@password}@grendel/users/#{@user_id}/linked-documents"
  end

  describe "list" do
    before do
      stub_json_request(:get, @base_uri, %{{
        "linked-documents":[
          {
            "name":"document1.txt",
            "uri":"http://grendel/users/alice/linked-documents/bob/document1.txt",
            "owner":{
              "id": "bob",
              "uri": "http://grendel/users/bob"
            }
          },
          {
            "name":"document2.txt",
            "uri":"http://grendel/users/alice/linked-documents/carol/document2.txt",
            "owner":{
              "id": "carol",
              "uri": "http://grendel/users/carol"
            }
          }

        ]
      }})
    end

    it "should return an array of all linked documents" do
      docs = @user.linked_documents.list
      docs.length.should == 2
      docs[0].name.should == "document1.txt"
      docs[0].uri.should == "/users/alice/linked-documents/bob/document1.txt"
      docs[0].owner.id.should == "bob"
      docs[0].owner.uri.should == "/users/bob"
      docs[1].name.should == "document2.txt"
      docs[1].uri.should == "/users/alice/linked-documents/carol/document2.txt"
      docs[1].owner.id.should == "carol"
      docs[1].owner.uri.should == "/users/carol"
    end
  end

  describe "find" do
    before do
      stub_json_request(:get, @base_uri + "/bob/document1.txt", "yay for me", :content_type => "text/plain")
      stub_json_request(:get, @base_uri + "/carol/notfound.txt", "", :status => [404, "Not Found"])
    end

    it "should return the document" do
      doc = @user.linked_documents.find("bob", "document1.txt")
      doc.name.should == "document1.txt"
      doc.content_type.should == "text/plain"
      doc.data.should == "yay for me"
      doc.owner.id.should == "bob"
    end

    it "should raise an exception if the document is not found" do
      lambda {
        @user.linked_documents.find("carol", "notfound.txt")
      }.should raise_error(Grendel::Client::HTTPException) {|error| error.message.should == "404 Not Found"}
    end
  end

  describe "delete" do
    before do
      stub_json_request(:delete, @base_uri + "/bob/document.txt", "", :status => [204, "No Content"])
      @linked_document = Grendel::LinkedDocument.new(@user, :name => "document.txt", :owner => {:id => "bob"})
    end

    it "should send a properly-formatted request" do
      @user.linked_documents.delete("bob", "document.txt")
      request(:delete, @base_uri + "/bob/document.txt").should have_been_made.once
    end
  end
end
