class SourceFile < CouchRest::Model::Base  
  use_database COUCHDB.database("source_file")
  
  property :name, String
  property :code, String
  property :lock, String
  property :locked_at, Time
  property :folder_id, String
  property :last_update, Time
  property :updated_by, String
  property :message, String
  
  timestamps!
  
  validates_presence_of :name
  
  # check uniqueness of name in same folder
  before_save do |source_file|
    source_file.errors.add(:name, :taken, :value => source_file.name) if files = SourceFile.all.select{|sf|sf.folder_id == source_file.folder_id and sf.name == source_file.name} and not files.blank? and not files.collect{|srcf|srcf.id}.include? source_file.id
    return false unless source_file.errors.blank?
  end
  
  def self.first
    all.first
  end
  
  # TODO create view
  def self.find_roots
    all.select{|sf|sf.folder_id.blank?}.sort_by{|sf|sf.name.andand.downcase || ""}
  end
  
  # generates the full path of the file
  def path_name
    path = ""
    if tmp_folder = folder
      path = tmp_folder.name + "/" + path
      while parent = tmp_folder.parent do
        path = parent.name + "/" + path
        tmp_folder = parent
      end
    end
    "/" + path
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
    @folder ||= Folder.find self.folder_id
  end
  
  def folder=(folder)
    folder_id = folder.id
  end
  
end
