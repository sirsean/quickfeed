require "pocket_share"

class SharingController < ApplicationController
  before_filter :require_login

  def index
    @apps = AppConsumerKey.all
    @user_tokens = {}
    UserAccessToken.where(:user_id => current_user.id).each do |token|
      @user_tokens[token.app] = token
    end
  end

  def start
    app_name = params[:app_name]

    @app = AppConsumerKey.where(:app => app_name).first

    session[:oauth_request_token] = PocketShare.get_request_token(request.host, @app)

    redirect_to "https://getpocket.com/auth/authorize?request_token=#{session[:oauth_request_token]}&redirect_uri=#{URI.encode_www_form_component(PocketShare.redirect_uri(request.host, @app))}"
  end

  def finish
    app_name = params[:app_name]

    @app = AppConsumerKey.where(:app => app_name).first

    access_token_response = PocketShare.get_access_token(@app, session[:oauth_request_token])

    user_access_token = UserAccessToken.create(
      :user_id => current_user.id,
      :app => @app.app,
      :token => access_token_response,
    )

    session.delete(:oauth_request_token)

    flash.notice = "You have authorized #{@app.app.capitalize}!"
    redirect_to "/sharing"
  end

  def remove
    app_name = params[:app_name]

    token = UserAccessToken.where(:user_id => current_user.id, :app => app_name).first

    if not token.nil?
      token.delete
    end

    flash.notice = "You have de-authorized #{app_name.capitalize}."
    redirect_to "/sharing"
  end
end
