class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def edit; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "sent_pass_reset_success"
      redirect_to root_url
    else
      flash.now[:danger] = t "email_not_exist"
      render :new
    end
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, t("not_empty")
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t "reset_pass_success"
      redirect_to @user
    else
      flash[:danger] = t "reset_pass_fail"
      render :edit
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "pass_reset_expired"
    redirect_to new_password_reset_path
  end

  private
  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by(email: params[:email])
    return template_not_found unless @user
  end

  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end
end
