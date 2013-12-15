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
    start_date = new_date(raw_start_date)
    end_date = new_date(raw_end_date)
    flash_msg(:error, "Invalied start_date: #{raw_start_date}") if start_date.nil?
    flash_msg(:error, "Invalied end_date: #{raw_end_date}") if end_date.nil?
    # fetch statuses between start_date and end_date
    if start_date.nil? || end_date.nil?
      render :new
    else
      # @statuses = fetch_statuses(start_date, end_date)
      # @data = Mash.new
      # @data.start_date = start_date
      # @data.end_date = end_date
      # @data.statuses = @statuses
      # File.open("statuses/#{session[:uid]}.json", "w") do |f|
      #   f.write(@data.to_json)
      # end
      # render :select
      File.open("statuses/#{session[:uid]}.json", "r") do |f|
        @statuses = Mash.new(JSON.load(f)).statuses
      end
    end
    
  end

  def create
    File.open("statuses/#{session[:uid]}.json", "r") do |f|
        @data= Mash.new(JSON.load(f))
    end
    fetched_statuses = @data.statuses
    @statuses = []
    fetched_statuses.each do |status|
      @statuses << status if params[status.id.to_s] == '1'
    end
    pdf = WickedPdf.new
    pdf = render_to_string(:pdf => "book.pdf",
                           :template => "books/print.pdf.erb",
                           :page_size => "A5")
    File.open("wbooks/#{session[:uid]}.pdf", "wb") do |f|
      f << pdf
    end
    redirect_to action: :show
  end
  def show
  end

  def send_email
    @addr = params[:email_addr]
    # XXX validate is not perfect !
    flash_msg(:error, "Invalied addr : #{@addr}") if invalid_email_addr?(@addr.to_s)
    if invalid_email_addr?(@addr.to_s) 
        render :show 
    else 
        CommentMailer.sendmail(@addr.to_s).deliver
    end
  end

  def create
    File.open("statuses/#{session[:uid]}.json", "r") do |f|
        @data= Mash.new(JSON.load(f))
    end
    fetched_statuses = @data.statuses
    @statuses = []
    fetched_statuses.each do |status|
      @statuses << status if params[status.id.to_s] == '1'
    end
    pdf = WickedPdf.new
    pdf = render_to_string(:pdf => "book.pdf",
                           :template => "books/print.pdf.erb",
                           :page_size => "A5")
    File.open("wbooks/#{session[:uid]}.pdf", "wb") do |f|
      f << pdf
    end
    redirect_to action: :show
  end

  def show
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
    end while current_statuses.length == count && (! select_end)
   
    return fetched_statuses
  end
end
