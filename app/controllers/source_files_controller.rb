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
    logger.error params.inspect
    source_file = SourceFile.create params
    flash[:success] = "Source File #{source_file.name} added." if source_file.errors.blank?
    redirect_to path.merge({:selected_id => source_file.id})
  end
  
  # TODO: add user lock
  def edit
    @source_file = SourceFile.find params[:id]
    @source_file.update_attributes :locked_at => Time.now
  end
  
  def download
    source_file = SourceFile.find params[:id]
    send_data source_file.code,
              :filename => source_file.name,
              :type => "text/plain"
    source_file.update_attributes :locked_at => Time.now
  end
  
  def update
    source_file = SourceFile.find params[:id]
    source_file.update_attributes params[:source_file]
    flash[:success] = "Source File #{source_file.name} updated." if source_file.errors.blank?
    redirect_to source_file_path(:id => source_file.id)
  end
  
  private 
  
  def initialize_request
    @folder = Folder.find params[:folder_id]
  end
  
end
