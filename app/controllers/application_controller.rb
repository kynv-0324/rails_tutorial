class ApplicationController < ActionController::Base
  before_action :set_locale
  include SessionsHelper

  private
  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def default_url_options
    {locale: I18n.locale}
  end

  # Confirms a logged-in user
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t("users.required_login")
    redirect_to login_url, status: :see_other
  end
end
