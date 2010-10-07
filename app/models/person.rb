class Person < CouchRest::Model::Base
  use_database COUCHDB.database("person")
  
  property :name
  property :user_name, String
  property :hashed_password, String
  property :salt, String
  
  validates_presence_of :password_confirmation, :if => :password_changed?
  validates_confirmation_of :password, :if => :password_changed?
  validates_length_of :password, :minimum => 8, :if => :password_changed?

  validates_presence_of :user_name
  validates_uniqueness_of :user_name
    
  # Temporary attribute to store password confirmation
  attr_accessor :password_confirmation
  # Temporary attribute to store old password
  attr_accessor :old_password
  
  def self.authenticate(user_name, password)
    if not user_name.blank? and person = find_by_user_name(user_name)
      unless person.hashed_password.blank?
        expected_password = encrypted_password(password, person.salt)
        if person.hashed_password == expected_password
          return person
        end
      end
    end
  end
  
  def self.find_by_user_name(user_name)
    all.select{|person| person.user_name == user_name}.first
  end
  
  def password
    @password
  end

  def password=(pwd)
    @password = pwd
    create_new_salt
    self.hashed_password = Person.encrypted_password(self.password, self.salt)
  end
  
  def password_changed?
    not password.blank?
  end

  #  changes the users password when all validations pass
  def change_password(params)
    if not Person.authenticate(self.user_name, params[:old_password])
      self.errors.add :old_password, "The old password is not correct."
    elsif params[:old_password] == params[:password]
      self.errors.add :password, "The new and old password should differ."
    elsif params[:password].blank?
      self.errors.add :password, "The new password can't be blank."
    elsif params[:password].size < 8
      self.errors.add :password, "The new password should be at least 8 characters long."
    elsif params[:password].size > 30
      self.errors.add :password, "The new password should be at most 30 characters long."
    elsif params[:password] != params[:password_confirmation]
      self.errors.add :password_confirmation, "The new password and its confirmation don't match."
    end
    self.update_attributes(params) if self.errors.empty? # change the password
  end
  
  private

  def self.encrypted_password(password, salt)
    string_to_hash = password + "hs,8&f4:" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end

  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end

end
