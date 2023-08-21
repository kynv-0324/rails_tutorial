module SessionsHelper
  def login user
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by id: user_id
    elsif user_id = cookies.encrypted[:user_id]
      user = User.find_by id: user_id
      if user&.authenticated? cookies[:remember_token]
        login user
        @current_user = user
      else
        @current_user = nil
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end

  # Forgets a persistent session
  def forget user
    user.forget
    cookies.delete :user_id
    cookies.delete :remember_token
  end

  # Logs out the current user.
  def logout
    forget current_user
    reset_session
    @current_user = nil
  end

  # Remembers a user in a persistent session.
  def remember user
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
end
