class PeopleController < ApplicationController
  
  def new
    session[:referer] = request.referer
  end
  
  def create
    person = Person.create params[:person]
    session[:person_id] = person.id
    flash[:success] = "Account created and logged in." if person.errors.blank?
    redirect_to session[:referer]
  end
  
  def edit
    if @person
      session[:referer] = request.referer
    else
      redirect_to :back
    end
  end
  
  def update
    if @person
      updates = params[:person]
      unless updates[:old_password].blank?
        @person.change_password params[:person]
      else
        updates.delete :password
        @person.update_attributes updates
      end
      flash[:success] = "Changes saved to your account." if @person.errors.blank?
    end
    redirect_to session[:referer]
  end
  
  def login
    session.delete :person_id
    unless params[:user_name].blank? or params[:password].blank?
      if person = Person.authenticate(params[:user_name], params[:password])
        person.update_attributes :last_login => Time.now
        session[:person_id] = person.id
      end
    end
    sleep 5 unless session[:person_id]
    redirect_to :back
  end
  
  def logout
    session.delete :person_id
    redirect_to :back
  end
  
end
