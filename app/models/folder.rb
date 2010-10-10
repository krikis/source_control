class Folder < CouchRest::Model::Base
  use_database COUCHDB.database("folder")

  property :name, String
  property :parent_id, String

  validates_presence_of :name
  
  # check uniqueness of name in same folder
  before_save do |folder|
    folder.errors.add(:name, :taken, :value => folder.name) if Folder.all.select{|f|f.parent_id == folder.parent_id}.collect{|fldr|fldr.name}.include? folder.name
    return false unless folder.errors.blank?
  end

  def self.first
    all.first
  end

  # TODO create view
  def self.find_roots
    all.select{|folder|folder.parent_id.blank?}.sort_by{|folder|folder.name.andand.downcase || ""}
  end
  
  def self.find_by_parent_id_and_name(parent_id, name)
    all.select{|folder|folder.parent_id == parent_id and folder.name == name}.first
  end

  def parent
    @parent ||= Folder.find self.parent_id
  end

  def parent=(parent)
    parent_id = parent.id
  end

  def children
    Folder.all.select{|sf|sf.parent_id == id}.sort_by{|folder|folder.name.andand.downcase || ""}
  end

  def source_files
    SourceFile.all.select{|sf|sf.folder_id == id}.sort_by{|sf|sf.name.andand.downcase || ""}
  end
  
  def destroy_folder
    if source_files.inject(true){|cond, sf|cond and sf.destroy_source_file} and children.inject(true){|cond, ch|cond and ch.destroy_folder}
      self.destroy
    end
  end

end
