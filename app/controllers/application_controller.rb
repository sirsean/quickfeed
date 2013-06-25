class ApplicationController < ActionController::Base
  protect_from_forgery
  helper_method :current_user, :logged_in?
  after_filter :set_csrf_cookie

  def current_user
    if session[:user_id]
      @current_user ||= User.find(session[:user_id])
    else
      @current_user = nil
    end
  end

  def logged_in?
    session.has_key?(:user_id)
  end

  def require_login
    unless logged_in?
      flash.alert = "You must be logged in"
      session[:last_uri] = request.fullpath
      redirect_to "/user/login"
    end
  end

  def not_found
    raise ActionController::RoutingError.new("Not Found")
  end

  def set_csrf_cookie
    if protect_against_forgery?
      cookies["XSRF-TOKEN"] = form_authenticity_token
    end
  end

  protected

  def verified_request?
    super || form_authenticity_token == request.headers["X-XSRF-TOKEN"]
  end
end
