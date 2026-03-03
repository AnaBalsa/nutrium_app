require "test_helper"

class AppointmentRequestMailerTest < ActionMailer::TestCase
  test "send_notification" do
    mail = AppointmentRequestMailer.send_notification
    assert_equal "send_notification", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
