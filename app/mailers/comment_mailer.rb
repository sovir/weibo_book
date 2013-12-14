#-*- encoding=utf-8 -*-

class CommentMailer < ActionMailer::Base
  def sendmail(email_to)
    #attachments['weibo-book.pdf']=File.read('./weibo-book.pdf')
    #mail(:subject => "#{subject}", :from => email_from, :cc => email_to) do |format|
    #TODO Chinese
    mail(:subject => "your weibo-book", :from => "hitwavebook@163.com", :cc => email_to) do |format|
      format.html
    end
  end

end
