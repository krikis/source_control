class FoldersController < ApplicationController
  
  def create
    path = hash_for_source_files_path.merge({:folder_id => params[:parent_id]})
    folder = Folder.create params
    flash[:success] = "Folder #{folder.name} added."
    redirect_to path.merge({:selected_id => folder.id})
  end
  
  def update
  end
end
