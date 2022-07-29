class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    action_user_login user, params[:session][:remember_me]
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

  def action_user_login user, remember
    if user&.authenticate(params[:session][:password])
      log_in user
      remember == "1" ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = t "login_fail"
      render :new
    end
  end
end