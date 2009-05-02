require File.join(File.dirname(__FILE__), 'abstract_unit')
require File.join(File.dirname(__FILE__), 'fixtures/state')

class ArrayDropdownTest < Test::Unit::TestCase  # :nodoc:
  fixtures :states

  def test_array_to_dropdown
    states = State.find(:all, :order => "id")
    assert_equal [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]], states.to_dropdown
  end

  def test_array_to_dropdown_change_text
    states = State.find(:all, :order => "id")
    assert_equal [["AL", 1], ["AK", 2], ["AZ", 3], ["CA", 4], ["CO", 5]], states.to_dropdown("abbreviation")
  end

  def test_array_to_dropdown_change_both
    states = State.find(:all, :order => "id")
    assert_equal [["Alabama", "AL"], ["Alaska", "AK"], ["Arizona", "AZ"], ["California", "CA"], ["Colorado", "CO"]], states.to_dropdown("name", "abbreviation")
  end

  def test_array_to_dropdown_include_blank
    states = State.find(:all, :order => "id")
    assert_equal [["", ""], ["AL", 1], ["AK", 2], ["AZ", 3], ["CA", 4], ["CO", 5]], states.to_dropdown("abbreviation", "id", true)
    assert_equal [["Select a State", ""], ["AL", 1], ["AK", 2], ["AZ", 3], ["CA", 4], ["CO", 5]], states.to_dropdown("abbreviation", "id", "Select a State")
  end
end