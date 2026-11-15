require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome_email" do
    user = users(:one)

    mail = UserMailer.with(user: user).welcome_email

    assert_equal "Welcome", mail.subject
    assert_equal [ user.email_address ], mail.to
    assert_equal [ "from@example.com" ], mail.from

    assert_match "Welcome to Depot!", mail.text_part.body.to_s
  end
end
