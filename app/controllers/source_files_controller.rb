class SourceFilesController < ApplicationController
  
  before_filter :initialize_request
  
  def index
    if @folder
      @folders = @folder.children
      @source_files = @folder.source_files
    else  
      @folders = Folder.find_roots
      @source_files = SourceFile.find_roots
    end
  end
  
  def show
    @source_file = SourceFile.find params[:id]
  end
  
  def create
    path = hash_for_source_files_path.merge({:folder_id => params[:folder_id]})
    source_file = SourceFile.create params
    flash[:success] = "Source File #{source_file.name} added."
    redirect_to path.merge({:selected_id => source_file.id})
  end
  
  def update
  end
  
  private 
  
  def initialize_request
    @folder = Folder.find params[:folder_id]
  end
  
end
