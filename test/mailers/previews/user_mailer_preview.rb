class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    user = User.first
    UserMailer.with(user: user).welcome_email
  end
end
