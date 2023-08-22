module SessionsHelper
  def login user
    session[:user_id] = user.id
    # Guard against session replay attacks.
    session[:session_token] = user.session_token
  end

  # Returns the current logged-in user (if any).
  def current_user
    if user_id = session[:user_id]
      user = User.find_by id: user_id
      if user && session[:session_token] == user.session_token
        @current_user = user
      end
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

  # Returns true if the given user is the current user.
  def current_user? user
    user && user == current_user
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

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
