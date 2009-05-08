require 'test_helper'

class MailmanTest < ActionMailer::TestCase
  test "receive" do
    @expected.subject = 'Mailman#receive'
    @expected.body    = read_fixture('receive')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Mailman.create_receive(@expected.date).encoded
  end

end
