class FoldersController < ApplicationController
  
  def create
    path = hash_for_source_files_path.merge({:folder_id => params[:parent_id]})
    if @person
      folder = Folder.create params
      flash[:success] = "Folder #{folder.name} added." if folder.errors.blank?
      redirect_to path.merge({:selected_id => folder.id})
    else
      redirect_to path
    end
  end
  
  def update
  end
end
