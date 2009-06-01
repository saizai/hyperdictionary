require 'test_helper'

class ProfileMailerTest < ActionMailer::TestCase
  test "update" do
    @expected.subject = 'ProfileMailer#update'
    @expected.body    = read_fixture('update')
    @expected.date    = Time.now

    assert_equal @expected.encoded, ProfileMailer.create_update(@expected.date).encoded
  end

end
