# Copyright (c) 2006 DeLynn Berry
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module DeLynnBerry
  module Dropdown
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      attr_accessor :dropdown_text_attr, :dropdown_value_attr, :include_blank, :find_arguments

      # Specify this act if you want to your model be used easily with the <tt>select</tt> form helper. By default the
      # plugin assumes you want to use the class' primary key for the option value and the <tt>name</tt> attribute for
      # the option text.
      #
      # The acts_as_dropdown class method operates much like the ActiveRecord#find method when it comes to customization.
      # You can alter the <tt>:text</tt> and <tt>:value</tt> attributes that are used. You can also alter what items are
      # collected from the database by passing in any of the regular ActiveRecord#find options (i.e. <tt>:conditions</tt>,
      # <tt>:order</tt>, <tt>:group</tt>, <tt>:limit</tt>, <tt>:offset</tt>, etc.)
      #
      # Examples:
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
      #   end
      #
      #   State.to_dropdown   # => [["AL", 1], ["AK", 2], ["AZ", 3]]
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :conditions => "id < 4", :order => "name DESC"
      #   end
      #
      #   State.to_dropdown   # => [["Arizona", 3], ["Alaska", 2], ["Alabama", 1]]
      #
      # The class method <tt>to_dropdown</tt> can also alter the default class configuration using the same options hash.
      #
      # Example:
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
      #   end
      #
      #   State.to_dropdown :text => "name", :conditions => nil   # => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
      #
      # == Configuration options
      #
      # * <tt>text</tt>           - This is the class attribute (database column) that will be used as the text/label for
      #                             the option tag (defaults to 'name').
      # * <tt>value</tt>          - This is the class attribute (database column) that will be used to fill in the option's
      #                             value parameter (defaults to the class' primary_key).
      # * <tt>include_blank</tt>  - Specify true if you'd like to have a blank item added to the beginning of your list, or
      #                             a string that will be placed in the value attribute of the option group.
      #
      # All of ActiveRecord#find options are available as well:
      #
      # * <tt>:conditions</tt>: An SQL fragment like "administrator = 1" or [ "user_name = ?", username ].
      # * <tt>:order</tt>: A SQL fragment like "created_at DESC, name".
      # * <tt>:group</tt>: An attribute name by which the result should be grouped. Uses the GROUP BY SQL-clause.
      # * <tt>:limit</tt>: An integer determining the limit on the number of rows that should be returned.
      # * <tt>:offset</tt>: An integer determining the offset from where the rows should be fetched. So at 5, it would skip the first 4 rows.
      # * <tt>:joins</tt>: An SQL fragment for additional joins like "LEFT JOIN comments ON comments.post_id = id". (Rarely needed).
      # * <tt>:include</tt>: Names associations that should be loaded alongside using LEFT OUTER JOINs. The symbols named refer
      #   to already defined associations. See eager loading under Associations.
      # * <tt>:select</tt>: By default, this is * as in SELECT * FROM, but can be changed if you for example want to do a join, but not
      #   include the joined columns.
      def acts_as_dropdown(*args)
        options = {:text => 'name', :value => self.primary_key}
        options.merge!(args.pop) unless args.empty?
        options.merge!(:order => options[:value]) unless options.has_key?(:order)

        self.dropdown_text_attr   = options.delete(:text)
        self.dropdown_value_attr  = options.delete(:value)
        self.include_blank        = options.delete(:include_blank)
        self.find_arguments       = options
      end
      
      # Examples:
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
      #   end
      #
      #   State.to_dropdown   # => [["AL", 1], ["AK", 2], ["AZ", 3]]
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :conditions => "id < 4", :order => "name DESC"
      #   end
      #
      #   State.to_dropdown   # => [["Arizona", 3], ["Alaska", 2], ["Alabama", 1]]
      #
      # The class method <tt>to_dropdown</tt> can also alter the default class configuration using the same options hash.
      #
      # Example:
      #
      #   class State < ActiveRecord::Base
      #     acts_as_dropdown :text => "abbreviation", :conditions => "id < 4"
      #   end
      #
      #   State.to_dropdown :text => "name", :conditions => nil   # => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
      #
      # See DeLynnBerry::Dropdown::ClassMethods#acts_as_dropdown for additional configuration options
      def to_options_for_select(*args)
        options = args.empty? ? {} : args.pop
        text    = options.delete(:text)
        value   = options.delete(:value)
        blank   = options.delete(:include_blank)
        options.merge!(:order => value) if (!value.nil? && self.dropdown_value_attr != value) && options.has_key?(:order) == false

        items = find(:all, options.empty? ? self.find_arguments : options).to_dropdown(text   || self.dropdown_text_attr,
                                                                                       value  || self.dropdown_value_attr)

        if args.empty? && self.include_blank
          items.insert(0, self.include_blank.kind_of?(String) ? [self.include_blank, ""] : ["", ""])
        elsif blank
          items.insert(0, blank.kind_of?(String) ? [blank, ""] : ["", ""])
        end
        items
      end
      alias :to_dropdown :to_options_for_select
    end
  end
end

ActiveRecord::Base.send(:include, DeLynnBerry::Dropdown)