class SourceFile < CouchRest::Model::Base  
  use_database COUCHDB.database("source_file")
  
  property :lock, String
  property :parent_id, String
  property :code, String
  
  def self.first
    all.first
  end
  
  # get the person that locked the file
  def person
    Person.find lock
  end
  
  # set lock on file to prevent editing
  def set_lock(lock)
    begin
      update_attributes :lock => lock
    rescue Exception => e
      flash[:error] = "The file could not be locked! Try again later."
    end
  end    
  
  def parent
    SourceFile.find self.parent_id
  end
  
  def children
    SourceFile.all.select{|sf|sf.parent_id == id}
  end
  
end
