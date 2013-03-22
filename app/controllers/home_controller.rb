class HomeController < ApplicationController
  def index
    if logged_in?
      redirect_to "/reader"
    end
  end
end
