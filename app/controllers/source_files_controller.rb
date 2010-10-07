class SourceFilesController < ApplicationController
  
  def index
    if params[:folder].blank?
    @folders = Folder.find_roots
      @source_files = SourceFile.find_roots
    elsif folder = Folder.find(params[:folder])  
      @folders = folder.children
      @source_files = folder.source_files
    end
  end
  
  def show
    @source_file = SourceFile.find params[:id]
  end
  
  def create
  end
  
  def update
  end
  
end
