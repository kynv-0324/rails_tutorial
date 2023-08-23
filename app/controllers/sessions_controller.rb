class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate(params[:session][:password])
      if user.activated?
        forwarding_url = session[:forwarding_url]
        reset_session
        params[:session][:remember_me] == "1" ? remember(user) : forget(user)
        login user
        redirect_to forwarding_url || user
      else
        flash[:warning] = t(".not_activated")
        redirect_to root_path
      end
    else
      # Create an error message
      flash.now[:danger] = t(".error")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout if logged_in?
    redirect_to root_url, status: :see_other
  end
end
