class BooksController < ApplicationController
  WeiboOAuth2::Config.api_key = '4286583364'
  WeiboOAuth2::Config.api_secret = 'b514220cea98656a0b74011b13334143'
  WeiboOAuth2::Config.redirect_uri = 'http://127.0.0.1:3000/callback'
  def new
  end

  def create
    # accept and check dates
    raw_start_date = params[:start_date].values.join('-')
    raw_end_date = params[:end_date].values.join('-')
    start_date = new_date(raw_start_date)
    end_date = new_date(raw_end_date)
    flash_msg(:error, "Invalied start_date: #{raw_start_date}") if start_date.nil?
    flash_msg(:error, "Invalied end_date: #{raw_end_date}") if end_date.nil?
    # fetch statuses between start_date and end_date
    if start_date.nil? || end_date.nil?
      render :new
    else
      # @total_statuses = fetch_statuses(start_date, end_date)
    end
    
  end

  def show
  end

  def send_mail
    @addr = params[:email_addr]
    # TODO validate the email addr
    CommentMailer.sendmail("hitwavebook@163.com", @addr.to_s, "hitwave", "your_weibo_book", @message).deliver
  end
  
  private
  def new_date(date)
    begin
      Date.parse(date)
    rescue ArgumentError
      nil
    end
  end
  
  def fetch_statuses(start_date, end_date)
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({access_token: session[:access_token],
                               expires_at: session[:expires_at]})
    total_statuses = []
    count = 10
    page_num = 0
    no_end = true
    # while no_end do
      page_num = page_num + 1
      current_statuses = client.statuses.user_timeline("uid" => session[:uid],
                                                       "count" => count,
                                                       "page" => page_num)
      render text: current_statuses.statuses
      # current_statuses.statuses.each do |status|
      #   created_date = Date.parse(status.created_at)
      #   if current_statuses
      #     no_end = false
      #     break
      #   end
      #   total_statuses << status if created_date <= end_date
      # end
    # end
    
    return total_statuses
  end
end
