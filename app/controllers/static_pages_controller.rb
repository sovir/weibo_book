class StaticPagesController < ApplicationController

  def home
    
  end
  def connect
    client = WeiboOAuth2::Client.new()
    redirect_to client.authorize_url
  end

end
