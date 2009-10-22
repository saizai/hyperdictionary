require 'test_helper'

class RelationshipMailerTest < ActionMailer::TestCase
  test "confirmation_request" do
    @expected.subject = 'RelationshipMailer#confirmation_request'
    @expected.body    = read_fixture('confirmation_request')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RelationshipMailer.create_confirmation_request(@expected.date).encoded
  end

  test "reciprocation_notice" do
    @expected.subject = 'RelationshipMailer#reciprocation_notice'
    @expected.body    = read_fixture('reciprocation_notice')
    @expected.date    = Time.now

    assert_equal @expected.encoded, RelationshipMailer.create_reciprocation_notice(@expected.date).encoded
  end

end
