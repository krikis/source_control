class FoldersController < ApplicationController
  
  def create
    path = hash_for_source_files_path.merge({:folder_id => params[:parent_id]})
    source_file = Folder.create params
    redirect_to path.merge({:selected_id => source_file.id})
  end
  
  def update
  end
end
