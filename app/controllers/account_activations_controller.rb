class AccountActivationsController < ApplicationController
  before_action :find_user, only: %i(edit)

  def edit
    if !@user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      login user
      flash[:success] = t "user_mailer.account_activation.success"
      redirect_to user
    else
      flash[:danger] = t "user_mailer.account_activation.fail"
      redirect_to root_path
    end
  end

  private
  def find_user
    @user = User.find_by email: params[:email]
    return if @user.present?

    redirect_to root_path, flash: {warning: t("users.index.error")}
  end
end
