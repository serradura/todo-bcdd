# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome
    mail(to: params[:email], subject: 'To-do B/CDD - Welcome') do |format|
      format.html do
        url = users_sign_in_url

        render('users/mailer/welcome', locals: {url:})
      end
    end
  end
end
