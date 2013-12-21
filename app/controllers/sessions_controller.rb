class SessionsController < ApplicationController
  include Hashie
  WeiboOAuth2::Config.api_key = '2065192073'
  WeiboOAuth2::Config.api_secret = '3a2eef3d956f160ff15dc17739c11009'
  WeiboOAuth2::Config.redirect_uri = 'http://weibo-books.herokuapp.com/callback'
  def new
    if sign_in?
      redirect_to new_book_url
    else
      reset_session
      client = WeiboOAuth2::Client.new
      redirect_to client.authorize_url
    end
  end

  def create
    client = WeiboOAuth2::Client.new
    access_token = client.auth_code.get_token(params[:code].to_s)
    session[:uid] = access_token.params["uid"]
    session[:access_token] = access_token.token
    session[:expires_at] = access_token.expires_at
    user = client.users.show_by_uid(session[:uid].to_s)
    session[:screen_name] = user.screen_name
    session[:created_at] = Date.parse("#{user.created_at}")
    data = Mash.new
    data.user = user
    File.open("statuses/#{session[:uid]}.json", "w") do |f| 
      f.write(data.to_json)
    end
    redirect_to new_book_url
  end

  def destroy
    reset_session
    redirect_to root_url
  end
end
