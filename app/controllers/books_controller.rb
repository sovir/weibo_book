# -*- coding: utf-8 -*-
class BooksController < ApplicationController
  require 'json'
  include Hashie
  WeiboOAuth2::Config.api_key = '4286583364'
  WeiboOAuth2::Config.api_secret = 'b514220cea98656a0b74011b13334143'
  WeiboOAuth2::Config.redirect_uri = 'http://127.0.0.1:3000/callback'
  def new
  end

  def select
    # accept and check dates
    raw_start_date = params[:start_date].values.join('-')
    raw_end_date = params[:end_date].values.join('-')
    book_name = params[:book_name]
    start_date = new_date(raw_start_date)
    end_date = new_date(raw_end_date)
    flash_msg(:error, "Invalied start_date: #{raw_start_date}") if start_date.nil?
    flash_msg(:error, "Invalied end_date: #{raw_end_date}") if end_date.nil?
    # check book_name
    flash_msg(:error, "book name can't be empty") if book_name.empty?
    # fetch statuses between start_date and end_date
    if start_date.nil? || end_date.nil? || book_name.empty?
      render :new
    else
      @statuses = fetch_statuses(start_date, end_date)
      File.open("statuses/#{session[:uid]}.json", "r") do |f|
        @data = Mash.new(JSON.load(f))
      end
      @data.template = params[:template]
      @data.start_date = start_date
      @data.end_date = end_date
      @data.book_name = book_name
      @data.statuses = @statuses
      File.open("statuses/#{session[:uid]}.json", "w") do |f|
        f.write(@data.to_json)
      end
      render :select
      # File.open("statuses/#{session[:uid]}.json", "r") do |f|
      #   @statuses = Mash.new(JSON.load(f)).statuses
      # end
    end
  end

  def create
    File.open("statuses/#{session[:uid]}.json", "r") do |f|
        @data= Mash.new(JSON.load(f))
    end
    @user = @data.user
    @statuses = []
    @data.statuses.reverse_each do |status|
      @statuses << status if params[status.id.to_s] == '1'
    end
    pdf = WickedPdf.new
    pdf = render_to_string(:pdf => "book.pdf",
                           :template => "books/template.pdf.erb",
                           :page_size => "A5",
                           :no_background => false)
    File.open("public/wbooks/#{session[:uid]}.pdf", "wb") do |f|
      f << pdf
    end
    redirect_to action: :show
  end

  def show
    
  end

  def down_pdf
    # XXX 这里的实现只支持一个用户一个pdf文件
    send_file "public/wbooks/#{session[:uid]}.pdf", :type => "application/pdf"
  end

  def share_book
    client = WeiboOAuth2::Client.new
    client.get_token_from_hash({access_token: session[:access_token], expires_at: session[:expires_at]})
    # get the 1st page of contant 
    require 'RMagick'
    # http://www.imagemagick.org/RMagick/doc/ilist.html#from_blob
    first_page_no = 3
    pdf_file = File.open("public/wbooks/#{session[:uid]}.pdf")
    blob = pdf_file.read
    ilist = Magick::ImageList.new
    ilist.from_blob(blob)
    ilist[first_page_no].write("public/wbooks/#{session[:uid]}.png")

    client.statuses.upload("#开源免费的微博书#我用这个网站制作了一本微博书哦，这是内容的第一页",File.open("public/wbooks/#{session[:uid]}.png"))
    flash_msg(:success, "已经分享到您的新浪微博啦～快去看看吧～ o(∩∩)o...哈哈")
    render :show
  end

  def send_email
    @addr = params[:email_addr]
    # TODO validate the email addr
    flash_msg(:error, "Invalied addr : #{@addr}") if invalid_email_addr?(@addr.to_s)
    if invalid_email_addr?(@addr.to_s) 
      render :show 
    else 
      CommentMailer.sendmail(@addr.to_s,
                             "public/wbooks/#{session[:uid]}.pdf").deliver
    end
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
    fetched_statuses = []
    page = 0
    count = 20
    fetch_end = false
    begin
      page = page + 1
      data = client.statuses.user_timeline("uid" => session[:uid],
                                           "page" => page,
                                           "count" => count,
                                           "trim_user" => 1)
      current_statuses = data.statuses
      current_statuses.each do |status|
        created_at = Date.parse(status.created_at)
        if created_at <= end_date
          if created_at >= start_date
            fetched_statuses << status
          else
            fetch_end = true
            break
          end
        end
      end
    end while current_statuses.length == count && (! fetch_end)
   
    return fetched_statuses
  end

end
