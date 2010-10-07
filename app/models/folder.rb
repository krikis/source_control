class Folder < CouchRest::Model::Base
  use_database COUCHDB.database("folder")
  
  property :name, String
  property :parent_id, String  
  
  validates_presence_of :name
  
  def self.first
    all.first
  end
  
  def self.find_roots
    all.select{|sf|sf.parent_id.blank?}
  end
  
  def parent
    Folder.find self.parent_id
  end
  
  def parent=(parent)
    parent_id = parent.id
  end

  def children
    Folder.all.select{|sf|sf.parent_id == id}
  end
  
  def source_files
    SourceFile.all.select{|sf|sf.folder_id == id}
  end
end
