class PeopleController < ApplicationController
  
  def login
    unless params[:user_name].blank? or params[:password].blank?
      if person = Person.authenticate(params[:user_name], params[:password])
        session[:person_id] = person.id
      end
    end
    redirect_to :back
  end
  
  def logout
    session.delete :person_id
    redirect_to :back
  end
  
end
