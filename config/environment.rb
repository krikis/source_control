# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SourceControl::Application.initialize!

# set couchdb db
COUCHDB = CouchRest.new
