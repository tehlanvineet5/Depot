
require "test_helper"

class SupportRequestMailerTest < ActionMailer::TestCase
  test "respond" do
    support_request = SupportRequest.new(
      email: "to@example.org",
      subject: "Support request",
      body: "Hi"
    )
    support_request.response = "Thank you for contacting us."

    mail = SupportRequestMailer.respond(support_request)

    assert_equal "Re: Support request", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "support@example.com" ], mail.from
    assert_match "Thank you for contacting us.", mail.body.encoded
  end
end
