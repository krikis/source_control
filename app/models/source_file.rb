class SourceFile < CouchRest::Model::Base  
  use_database COUCHDB.database("source_file")
  
  property :name, String
  property :code, String
  property :lock, String
  property :folder_id, String
  property :last_update, Time
  property :updated_by, String
  property :message, String
  
  timestamps!
  
  validates_presence_of :name
  
  def self.first
    all.first
  end
  
  def self.find_roots
    all.select{|sf|sf.folder_id.blank?}
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
  
  def folder
    SourceFile.find self.folder_id
  end
  
  def folder=(folder)
    folder_id = folder.id
  end
  
end
