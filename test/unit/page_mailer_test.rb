require 'test_helper'

class PageMailerTest < ActionMailer::TestCase
  test "update" do
    @expected.subject = 'PageMailer#update'
    @expected.body    = read_fixture('update')
    @expected.date    = Time.now

    assert_equal @expected.encoded, PageMailer.create_update(@expected.date).encoded
  end

end
