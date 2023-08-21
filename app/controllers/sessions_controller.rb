class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page
      reset_session
      login user
      redirect_to user
    else
      # Create an error message
      flash.now[:danger] = t("sessions.create.error")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    logout
    redirect_to root_url, status: :see_other
  end
end
