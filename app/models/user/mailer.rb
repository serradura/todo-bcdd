# frozen_string_literal: true

class User::Mailer < ApplicationMailer
  def welcome
    mail(to: params[:email], subject: 'To-do B/CDD - Welcome') do |format|
      format.html do
        url = users_sign_in_url

        render('users/mailer/welcome', locals: {url:})
      end
    end
  end

  def reset_password
    email = params[:email]

    mail(to: email, subject: 'To-do B/CDD - Reset password instructions') do |format|
      format.html do
        url = users_reset_password_url(uuid: params[:reset_password_token])

        render('users/mailer/reset_password', locals: {email:, url:})
      end
    end
  end
end
