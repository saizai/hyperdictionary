module DeLynnBerry
  module Dropdown
    # Collects the contents of the array and creates a new array that can be easily used
    # with the <tt>select</tt> form helper method.
    #
    # == Options
    #
    # * <tt>text</tt>           - This is the attribute that will be used as the text/label for the option tag (defaults to 'name').
    # * <tt>value</tt>          - This is the attribute that will be used to fill in the option's value parameter (defaults to 'id').
    # * <tt>include_blank</tt>  - Specify true if you'd like to have a blank item added to the beginning of your aray, or
    #                             a string that will be placed in the value attribute of the option group.
    #
    # === Example
    #   >> @states = State.find(:all, :order => "id")
    #   >> @states.to_dropdown 
    #   => [["Alabama", 1], ["Alaska", 2], ["Arizona", 3], ["California", 4], ["Colorado", 5]]
    def to_options_for_select(text = :name, value = :id, include_blank = false)
      items = self.collect { |x| [x.send(text.to_sym), x.send(value.to_sym)] }

      if include_blank
        items.insert(0, include_blank.kind_of?(String) ? [include_blank, ""] : ["", ""])
      end

      items
    end
    alias :to_dropdown :to_options_for_select
  end
end

class Array #:nodoc:
  include DeLynnBerry::Dropdown
end