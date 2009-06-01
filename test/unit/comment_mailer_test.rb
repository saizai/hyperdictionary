require 'test_helper'

class CommentMailerTest < ActionMailer::TestCase
  test "new" do
    @expected.subject = 'CommentMailer#new'
    @expected.body    = read_fixture('new')
    @expected.date    = Time.now

    assert_equal @expected.encoded, CommentMailer.create_new(@expected.date).encoded
  end

end
