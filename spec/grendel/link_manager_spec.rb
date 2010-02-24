require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# - get a list of documents a user has linked to them
# docs = user.linked_documents.list
# - retrieve a linked document
# doc = user.linked_documents.find("owner_user_id", "document.txt")
# - delete a linked document
# user.linked_documents.delete("owner_user_id", "document.txt")

describe "Grendel::LinkManager" do
  before do
    @client = Grendel::Client.new("http://grendel")
    @user_id = "alice"
    @password = "s3kret"
    @user = Grendel::User.new(@client, :id => @user_id, :password => @password)
    @document = Grendel::Document.new(@user, :name => "document1.txt")
    @uri = "#{@user_id}:#{@password}@grendel/users/#{@user_id}/documents/#{@document.name}/links"
  end

  describe "list" do
    before do
      stub_json_request(:get, @uri, %{{
        "links":[
          {
            "user":{
              "id":"bob",
              "uri":"http://grendel/users/bob"
            },
            "uri":"http://grendel/users/alice/documents/document1.txt/links/bob"
          },
          {
            "user":{
              "id":"carol",
              "uri":"http://grendel/users/carol"
            },
            "uri":"http://grendel/users/alice/documents/document1.txt/links/carol"
          }]
      }})
    end
    
    it "should list users with links to this document" do
      links = @document.links.list
      links.length.should == 2
      links[0].user.id.should == "bob"
      links[0].uri.should == "/users/alice/documents/document1.txt/links/bob"
      links[1].user.id.should == "carol"
      links[1].uri.should == "/users/alice/documents/document1.txt/links/carol"
    end
  end

  describe "add" do
    before do
      @other_user_id = "bob"
      stub_json_request(:put, @uri + "/" + @other_user_id, "")
    end
    
    it "should send a properly-formatted request" do
      @document.links.add(@other_user_id)
      request(:put, @uri + "/" + @other_user_id).should have_been_made.once
    end
    
    it "should return a Link object" do
      link = @document.links.add(@other_user_id)
      link.document.should == @document
      link.user.id.should == @other_user_id
    end
  end
  
  describe "remove" do
    before do
      @other_user_id = "bob"
      stub_json_request(:delete, @uri + "/" + @other_user_id, "")
    end

    it "should send a properly-formatted request" do
      @document.links.remove(@other_user_id)
      request(:delete, @uri + "/" + @other_user_id).should have_been_made.once
    end    
  end
end
