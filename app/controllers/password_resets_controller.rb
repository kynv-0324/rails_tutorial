class PasswordResetsController < ApplicationController
  before_action :find_user, only: %i(create)
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t("password_resets.new.sent_request")
    redirect_to root_path
  end

  def edit; end

  def update
    if params[:user][:password].empty? ||
       params[:user][:password_confirmation].empty?
      @user.errors.add(:password)
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
      reset_session
      login @user
      @user.update_column :reset_digest, nil
      flash[:success] = t(".success")
      redirect_to @user
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def find_user
    @user = User.find_by email: params[:password_reset][:email].downcase
    return if @user.present?

    flash.now[:danger] = t("users.index.error")
    render :new, status: :unprocessable_entity
  end

  def get_user
    @user = User.find_by email: params[:email]
    return if @user.present?

    redirect_to root_path,
                flash: {warning: t("users.index.error")}
  end

  # Confirms a valid user.
  def valid_user
    return if @user && @user.activated? &&
              @user.authenticated?(:reset, params[:id])

    redirect_to root_path, flash: {warning: t("users.index.error")}
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t(".request_expired")
    redirect_to new_password_reset_path
  end
end
