module SessionsHelper
  def signin

  end
  
  def sign_in?
    client = WeiboOAuth2::Client.new('4286583364',
                                     'b514220cea98656a0b74011b13334143')
    token = client.get_token_from_hash(access_token: session[:access_token], expires_at: session[:expires_at]) if session[:access_token]
    token && token.validated?
  end
end
