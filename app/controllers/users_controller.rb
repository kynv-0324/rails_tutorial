class UsersController < ApplicationController
  def show
    @user = User.find_by id: params[:id]
    redirect_to root_path, flash: {danger: t("users.index.error")} if @user.nil?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t("users.new.success")
      redirect_to @user
    else
      flash[:danger] = t("users.new.error")
      render :new, status: :unprocessable_entity
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
