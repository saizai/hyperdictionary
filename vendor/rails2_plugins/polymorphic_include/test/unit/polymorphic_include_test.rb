require File.join(File.dirname(__FILE__), '..', 'test_helper')
require File.join(File.dirname(__FILE__), '..', '..', 'init')

class PolymorphicIncludeTest < Test::Unit::TestCase

  def setup
    @mother = Mother.create
    @father = Father.create
    @child = Child.create :parent => @mother
    @child2 = Child.create :parent => @father
    @toy = Toy.create :child => @child
  end

  def teardown
    [Mother, Father, Child, Toy].each {|obj| obj.destroy_all}
  end

  def test_single_element
    assert_nothing_raised { Child.find(:all, :include => :parent) }
  end

  def test_array
    assert_nothing_raised { Child.find(:all, :include => [:parent]) }
  end

  def test_hash
    assert_nothing_raised { Child.find(:all, :include => {:parent => [:children]}) }
  end
  
  def test_mix_of_polymorphic_and_single_includes
    assert_nothing_raised { Child.find(:all, :include => [:toy, :parent]) }    
  end
end
