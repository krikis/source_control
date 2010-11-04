require 'test_helper'

class SourceFileTest < ActiveSupport::TestCase
  
  test "creating a source file without a name" do
    sf = SourceFile.create
    assert (not sf.valid?)
    assert sf.errors.first == [:name, "can't be blank"]
    assert SourceFile.find_by_folder_id_and_name("", "") == nil
  end

  test "creating a source file with a name" do
    source_file = SourceFile.find_by_folder_id_and_name("", "my_test_file.rb")
    source_file.destroy if source_file
    sf = SourceFile.create :name => "my_test_file.rb", :folder_id => ""
    assert sf.valid?
    assert sf.errors.empty?
    assert sf.id
    assert source_file = SourceFile.find_by_folder_id_and_name("", "my_test_file.rb")
  end

  test "creating a source file with an existing name" do
    source_file = SourceFile.find_by_folder_id_and_name("", "my_test_file.rb")
    source_file.destroy if source_file
    sf = SourceFile.create :name => "my_test_file.rb", :folder_id => ""
    assert sf.valid?
    assert sf.errors.empty?
    assert sf.id
    assert source_file = SourceFile.find_by_folder_id_and_name("", "my_test_file.rb")
    sf2 = SourceFile.create :name => "my_test_file.rb", :folder_id => ""
    assert (not sf2.id)
  end
end
