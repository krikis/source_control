class SourceFile < CouchRest::Model::Base
  use_database COUCHDB.database("source_file")

  property :name, String
  property :cached_path_name, String
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

  def self.find_by_folder_id_and_name(folder_id, name)
    all.select{|folder|folder.folder_id == folder_id and folder.name == name}.first
  end

  # full path of the file
  def path_name
    self.cached_path_name ||= generate_path_name
    save
    cached_path_name
  end

  # generates the full path of the file
  def generate_path_name
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

  # locates the file to the new path if changed
  def path_name=(path)
    if not path.blank? and path != cached_path_name
      check_uniqueness = true
      folders = path.split("/")
      folders.shift
      folders.each_with_index do |name, index|
        if index == 0
          parent_id = ""
        else
          parent_id = folders[index - 1].id
        end
        folder = Folder.find_by_parent_id_and_name parent_id, name
        unless folder
          folder = Folder.create(:parent_id => parent_id, :name => name)
          check_uniqueness = false
          self.errors.add :path_name, "path couldn't be created" unless folder
          return unless self.errors.blank?
        end
        folders[index] = folder
      end
      flder_id = (folders.blank? ? "" : folders.last.id)
      unless check_uniqueness and sf = SourceFile.find_by_folder_id_and_name(flder_id, self.name)
        self.update_attributes :folder_id => flder_id,
                               :cached_path_name => nil
      end
    end
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

  def destroy_source_file
    self.destroy unless lock
  end

end
