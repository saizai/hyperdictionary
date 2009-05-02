require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/state')
require File.join(File.dirname(__FILE__), 'fixtures/status')

class ActiveRecordDropdownTest < Test::Unit::TestCase  # :nodoc:
  fixtures :states, :statuses

  def test_class_method
    assert_equal [["Alabama", 1], ["Alaska", 2], ["Arizona", 3]],
                 State.to_dropdown
  end

  def test_class_method_custom_conditions
    assert_equal [["Alabama", 1], ["Alaska", 2], ["Arizona", 3]],
                 State.to_dropdown(:conditions => "id < 4")
  end

  def test_class_method_change_text
    assert_equal [["AL", 1], ["AK", 2], ["AZ", 3]],
                 State.to_dropdown(:text => "abbreviation")
  end

  def test_class_method_change_text_custom_conditions
    assert_equal [["AL", 1], ["AK", 2], ["AZ", 3]],
                 State.to_dropdown(:text => "abbreviation", :conditions => "id < 4")
  end

  def test_class_method_change_value
    assert_equal [["Alaska", "AK"], ["Alabama", "AL"], ["Arizona", "AZ"], ["California", "CA"], ["Colorado", "CO"]],
                 State.to_dropdown(:value => "abbreviation")
  end

  def test_class_method_change_value_custom_conditions
    assert_equal [["Alaska", "AK"], ["Alabama", "AL"], ["Arizona", "AZ"]],
                 State.to_dropdown(:value => "abbreviation", :conditions => "id < 4")
  end

  def test_class_method_change_text_change_value
    assert_equal [["AL", "Alabama"], ["AK", "Alaska"], ["AZ", "Arizona"], ["CA", "California"], ["CO", "Colorado"]],
                 State.to_dropdown(:text => "abbreviation", :value => "name")
  end

  def test_class_method_change_text_change_value_custom_conditions
    assert_equal [["AL", "Alabama"], ["AK", "Alaska"], ["AZ", "Arizona"]],
                 State.to_dropdown(:text => "abbreviation", :value => "name", :conditions => "id < 4")
  end

  def test_class_method_custom_order
    assert_equal [["Colorado", 5], ["California", 4], ["Arizona", 3], ["Alabama", 1], ["Alaska", 2]],
                 State.to_dropdown(:order => "abbreviation DESC")
  end

  def test_class_method_custom_order_custom_conditions
    assert_equal [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4]],
                 State.to_dropdown(:order => "name", :conditions => "id < 5")
  end

  def test_class_method_change_all
    assert_equal [[3, "AZ"], [1, "AL"], [2, "AK"]],
                 State.to_dropdown(:text => "id", :value => "abbreviation", :order => "abbreviation DESC", :conditions => "id < 4")
  end

  def test_class_method_include_blank
    assert_equal [["", ""], ["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]],
                 State.to_dropdown(:conditions => nil, :order => "name", :include_blank => true)
    assert_equal [["Select a State", ""], ["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]],
                 State.to_dropdown(:conditions => nil, :order => "name", :include_blank => "Select a State")
  end

  def test_class_method_different_value
    assert_equal [["Bad", "B"], ["Good", "G"]],
                 Status.to_dropdown
  end

end