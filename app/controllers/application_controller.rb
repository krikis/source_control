class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :log_session

  def log_session
    logger.info session.inspect
  end
end
