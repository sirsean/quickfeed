class UserController < ApplicationController
  before_filter :require_login, :only => [:edit, :passwd]

  def login
    if request.post?
      user_data = params[:user]
      if user = User.find_by_username(user_data[:username]).try(:authenticate, user_data[:password])
        session[:user_id] = user.id
        if session.has_key?(:last_uri)
          last_uri = session[:last_uri]
          session.delete(:last_uri)
          redirect_to last_uri
        else
          redirect_to "/reader"
        end
      else
        @user = User.new(:username => user_data[:username])
        flash.now.alert = "Login failed"
      end
    else
      @user = User.new
    end
  end

  def logout
    session.delete(:user_id)
    redirect_to "/"
  end

  def register
    if request.post?
      user_data = params[:user]
      @user = User.new(:username => user_data[:username], :email => user_data[:email])
      @user.signup_code = user_data[:signup_code]
      if not user_data[:password].empty?
        @user.password = user_data[:password]
        @user.password_confirmation = user_data[:password_confirmation]

        if @user.save
          session[:user_id] = @user.id
          if session.has_key?(:last_uri)
            last_uri = session[:last_uri]
            session.delete(:last_uri)
            redirect_to last_uri
          else
            redirect_to "/reader"
          end
        end
      else
        flash.now.alert = "You must specify a password"
      end
    else
      @user = User.new
    end
  end

  def show
    @user = User.find_by_username(params[:username]) || not_found
  end

  def edit
  end

  def passwd
    @user = current_user
    if request.post?
      user_data = params[:user]
      if user_data[:password].empty?
        flash.now.alert = "You must specify a new password"
      elsif current_user.try(:authenticate, user_data[:current_password])
        @user.password = user_data[:password]
        @user.password_confirmation = user_data[:password_confirmation]

        if @user.save
          flash.notice = "Password updated"
          redirect_to "/user/edit"
        end
      else
        flash.now.alert = "Incorrect current password"
      end
    end
  end
end
