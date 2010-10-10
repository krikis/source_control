class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :log_session, :initialize_request

  def log_session
    logger.info session.inspect
  end
  
  def initialize_request
    @person = Person.find session[:person_id]
  end
end
