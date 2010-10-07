class SourceFilesController < ApplicationController
  
  def index
    if params[:folder].blank?
      @source_files = SourceFile.all.select{|sf|sf.parent_id.blank?}
    elsif folder = Folder.find params[:folder]
      @source_files = folder.source_files
    end
  end
  
  def show
    @source_file = SourceFile.find params[:id]
  end
  
  def create
  end
  
  def update
    en
  
end
