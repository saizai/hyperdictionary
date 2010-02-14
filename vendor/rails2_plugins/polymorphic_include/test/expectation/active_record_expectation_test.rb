require File.join(File.dirname(__FILE__), '..', 'test_helper')

class ActiveRecordExpectationTest < Test::Unit::TestCase

  def test_include_polymorphic_association_throws_exception
    assert_raises(ActiveRecord::EagerLoadPolymorphicError) { Child.find(:all, :include => [:parent]) }
  end
end
