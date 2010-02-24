grendel-ruby
============

Ruby interface to the Grendel secure document storage service (http://github.com/wesabe/grendel). See the Grendel API documentation (http://github.com/wesabe/grendel/blob/master/API.md) for more information.

Installation
------------

If you haven't already added the github gem repository:

    gem sources -a http://gems.github.com

then:

    gem install wesabe-grendel-ruby

Examples
--------

The following examples assumes that you have the Grendel server running locally on port 8080.


### Establishing a Connection

    client = Grendel::Client.new("http://localhost:8080")


### Listing Registered Users

    client.users.list  # returns an array of Grendel::Users    


### Creating A New User

    user = client.users.create("alice", "s3kret")  # returns a Grendel::User with id "alice" and password "s3kret"
    
If the user `id` is taken, a `Grendel::HTTPException` will be thrown with a message containing `422 Unprocessable Entity` and an explanation.


### Viewing A User

    user = client.users.find("alice")  # returns a Grendel::User
    
    # return a Grendel::User with the password set to "s3kret". Note that this is merely a convenience
    # method for future authenticated calls--it does not actually check that the password is correct.
    user = client.users.find("alice", "s3kret")

The returned `Grendel::User` will contain the following attributes:

    id - user id
    modified_at - DateTime
    created_at - DateTime
    keys - array of key fingerprints
    
If the user is not found, a `Grendel::HTTPException` will be thrown with a message containing `404 Not Found`


### Changing A User's Password

    user = client.users.find("alice", "s3kret")
    user.change_password("new-pass")
    

### Deleting A User

    user = client.users.find("alice", "s3kret")
    user.delete


### Listing A User's Documents

    user = client.users.find("alice", "s3kret")
    docs = user.documents.list  # returns an array of Grendel::Documents

A `Grendel::Document` contains the following attributes:

    - name
    - data
    - content_type
    - uri


### Viewing A User's Document

    user = client.users.find("alice", "s3kret")
    doc = user.documents.find("document1.txt")  # returns a Grendel::Document


### Storing A User's Document

    user = client.users.find("alice", "s3kret")
    doc = user.documents.store("document1.txt", "i am a super secret")

The content type can be specified as an optional third parameter. If not provided,
it will be guessed from the file extension of the document name.

    doc = user.documents.store("document1.txt", "i am a super secret", "text/plain")

Note that this method will overwrite the document if it already exists in Grendel.


### Deleting A User's Document

    user = client.users.find("alice", "s3kret")
    doc = user.documents.delete("document1.txt")
    
    # or
    
    doc = user.documents.find("document1.txt")
    doc.delete


## Linking Documents

A Grendel document can be linked by its owner with other users. Doing so
provides other users *read-only* access to the document.


### Viewing A Document's Linked Users

    user = client.users.find("alice", "s3kret")
    doc = user.documents.find("document1.txt")
    links = doc.links.list  # returns an array of Grendel::Links
    
A `Grendel::Link` contains the following attributes:

    - document
    - user # the user the document is linked to
    - uri # the uri of the linked document


### Linking Another User To A Document

    user = client.users.find("alice", "s3kret")
    doc = user.documents.find("document1.txt")
    doc.links.add("bob")  # returns a Grendel::Link

User `bob` will now have read-only access to the document.


### Unlinking A User From A Document

    user = client.users.find("alice", "s3kret")
    doc = user.documents.find("document1.txt")
    doc.links.remove("bob")

User `bob` will no longer have access to the document.


## Managing Linked Documents

The documents shared with a user are stored in their own namespace to avoid
document name collisions. If the document's owner modifies the document, the
linked users will see the changes. Likewise, if the document's owner deletes the
document (or the owner is deleted), the documents will be removed from the
user's linked documents.


### Listing A User's Linked Documents


    user = client.users.find("alice", "s3kret")
    linked_docs = user.linked_documents  # returns an array of Grende::LinkedDocuments
    
A `Grendel::LinkedDocument` is a subclass of `Grendel::Document` with the following additional attribute:

    - owner # the document owner as a Grendel::User


### Viewing A Linked Document


    user = client.users.find("alice", "s3kret")
    doc = user.linked_documents.find("bob", "bobs_secrets.txt")
    

### Deleting A Linked Document

    user = client.users.find("alice", "s3kret")
    user.linked_documents.delete("bob", "bobs_secrets.txt")
    
    # or
    
    doc = user.linked_documents.find("bob", "bobs_secrets.txt")
    doc.delete

**This will *not* delete the document itself**, it will simply remove the
document from the user's list of linked documents. It will also **not**
re-encrypt the document; the next time the document is written to, however, the
user will be excluded from the recipients.

## Bugs and Issues

Please submit them here [http://github.com/wesabe/grendel-ruby/issues](http://github.com/wesabe/grendel-ruby/issues)

## Copyright

Copyright 2010 Wesabe, Inc. See LICENSE for details.