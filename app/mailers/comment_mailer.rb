#-*- encoding=utf-8 -*-

class CommentMailer < ActionMailer::Base
  #default from: "from@example.com"

  # def sendmail(email_from, email_to, sender_name, subject, message)
  #   @message = message
  #   #attachments['weibo-book.pdf']=File.read('./weibo-book.pdf')
  #   mail(:subject => "#{subject}", :from => email_from, :cc => email_to) do |format|
  #     format.html
  #   end
  # end
  def sendmail(email_to, book_path)
    attachments["weibo-book.pdf"]=File.read(book_path)
    #mail(:subject => "#{subject}", :from => email_from, :cc => email_to) do |format|
    #TODO Chinese
    mail(:subject => "your weibo-book", :from => "hitwavebook@163.com", :cc => email_to) do |format|
      format.html
    end
  end
end
