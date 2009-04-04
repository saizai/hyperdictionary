require File.dirname(__FILE__) + '/test_helper'

class ActsAsPreferencedTest < Test::Unit::TestCase
  fixtures :preferences, :users

  def setup
    @user = users(:josh)
  end
  
  def test_blank_values_should_be_set_to_nil
    p = @user.set_preference({'simple' => ''})
    assert_nil @user.get_preference('simple')
  end
  
  def test_should_allow_symbols_and_strings_as_interchangable_identifiers
    @user.set_preference({:sym => 'test'})
    assert_equal 'test', @user.get_preference(:sym), 'did not retrieve preference with symbol identifier'
    assert_equal 'test', @user.get_preference('sym'), 'did not retrieve preference with string identifier'
    @user.set_preference({'string' => 'another'})
    assert_equal 'another', @user.get_preference(:string), 'did not retrieve preference with symbol identifier'
    assert_equal 'another', @user.get_preference('string'), 'did not retrieve preference with symbol identifier'
  end
    
  def test_should_create_preference_from_hash
    assert_difference Preference, :count do
      p = @user.set_preference({:simple => 'damn right'})
      assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
    end
  end

  def test_should_create_many_preferences_from_hash
    assert_difference Preference, :count, 4 do
      p = @user.set_preference({:simple => 'damn right', :easy => 'as pie', :better => 'than chocolate', :you => 'like'})
      assert_equal 4, p.length
    end
  end
  
  def test_should_only_create_hash_based_preferences_one_level_deep
    assert_difference Preference, :count, 2 do
      p = @user.set_preference({:complex => {:something => {:crazy => 'nested'}}, :simple => 'test'})
    end
  end
  
  def test_should_handle_nil_hashes_gracefully
    assert_no_difference Preference, :count do
      p = @user.set_preference({})
      assert_equal nil, p
    end
  end
  
  def test_should_create_a_text_based_preference
    assert_difference Preference, :count do
      p = @user.set_preference('send_me_spam',true)
      assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_create_a_class_based_preference
    assert_difference Preference, :count do
      p = @user.set_preference('show_stats',true, User)
      assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_create_an_association_based_preference
    assert_difference Preference, :count do
      p = @user.set_preference('monitor_profile_changes', true, users(:aaron))
      assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_allow_setting_nil_preference_values
    assert_no_difference Preference, :count do
      p = @user.set_preference('work_order_approval_notification', nil)
      assert !p.new_record?, "#{p.errors.full_messages.to_sentence}"
    end
  end
  
  def test_should_change_value_of_existing_preference
    assert_difference Preference, :count do
      @user.set_preference('best_guess', 'horse', users(:aaron))
    end
    assert_no_difference Preference, :count do
      p = @user.set_preference('best_guess', 'unicorn', users(:aaron))
      assert_equal 'unicorn', p.value 
    end
  end
  
  def test_should_not_overwrite_preferences_within_other_scopes
    assert_difference Preference, :count do
      @user.set_preference('scope test', 'one')
    end
    assert_difference Preference, :count do
      @user.set_preference('scope test', 'two', User)
    end
    assert_difference Preference, :count do
      @user.set_preference('scope test', 'three', users(:aaron))
    end
    assert_equal 'one',   @user.get_preference('scope test')
    assert_equal 'two',   @user.get_preference('scope test', User)
    assert_equal 'three', @user.get_preference('scope test', users(:aaron))
  end
  
  def test_should_not_allow_duplicate_preferences_within_preferred_scope_even_when_created_directly
    assert_difference Preference, :count do
      p = Preference.create(:preferred => users(:josh), :preferrer => users(:josh), :name => 'dupe', :value => true)
    end
    assert_no_difference Preference, :count do
      p = Preference.create(:preferred => users(:josh), :preferrer => users(:josh), :name => 'dupe', :value => true)
      assert p.value
    end
  end
  
  def test_should_get_existing_preference_value_by_name
    assert_equal true, @user.get_preference('work_order_assignment_notification')
  end
  
  def test_should_get_existing_preference_value_by_name_and_object
    assert_equal 'weekly', @user.get_preference('watch', users(:aaron))
  end
  
  def test_should_get_existing_preference_value_by_name_and_class
    assert_equal true, @user.get_preference('hidden', User)
  end
  
  def test_should_require_name
    assert_no_difference Preference, :count do
      p = @user.set_preference(nil, 'ponies', users(:aaron))
      assert p.errors.on(:name), "name should have been required"
    end
  end
  
  def test_destroying_preferrer_should_destroy_associated_preferences
    cnt = @user.preferences.count
    assert_difference Preference, :count, -cnt do
      @user.destroy
    end
  end
  
  def test_should_provide_dynamic_methods_for_setting_string_preferences
    assert_difference Preference, :count do
      @user.email_notification_preference = true
    end
  end
  
  def test_should_provide_dynamic_methods_for_getting_string_preferences
    assert_equal false, @user.work_order_approval_notification_preference
  end
   
end