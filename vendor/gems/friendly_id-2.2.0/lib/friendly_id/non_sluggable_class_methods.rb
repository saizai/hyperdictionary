# encoding: utf-8

module FriendlyId::NonSluggableClassMethods

  include FriendlyId::Helpers

  protected

  def find_one(id, options) #:nodoc:#
    if id.is_a?(String)
      has_scope = options.has_key? :scope
      if has_scope # if it's not sluggable, we assume that the scope is a column name (and not something fancy like a method or association)
        scope = options.delete(:scope)
        result = send("find_by_#{ friendly_id_options[:column] }_and_#{friendly_id_options[:scope]}", id, scope, options)
      else
        result = send("find_by_#{ friendly_id_options[:column] }", id, options)
      end
      raise ActiveRecord::RecordNotFound if !result
      result.send(:found_using_friendly_id=, true)
    else
      result = super id, options
    end
    result
  end

  def find_some(ids_and_names, options) #:nodoc:#
    scopable = friendly_id_options.has_key? :scope
    has_scope = options.has_key? :scope
    scoped_find_options = {}
    if has_scope
      scope = options.delete(:scope)
      scoped_find_options[:conditions] = {friendly_id_options[:scope] => scope }
    end
    
    results = with_scope :find => options do
      with_scope :find => scoped_find_options do
        find :all, :conditions => ["#{quoted_table_name}.#{primary_key} IN (?) OR #{friendly_id_options[:column].to_s} IN (?)",
          ids_and_names, ids_and_names]
        end
    end
    
    expected = expected_size(ids_and_names, options)
    if ((!scopable or has_scope) and results.size != expected) or (scopable and !has_scope and results.size < expected) # with scope unspecified there might be more
      raise ActiveRecord::RecordNotFound, "Couldn't find all #{ name.pluralize } with IDs (#{ ids_and_names * ', ' }) AND #{ sanitize_sql options[:conditions] } (found #{ results.size } results, but was looking for #{ expected })"
    end

    results.each {|r| r.send(:found_using_friendly_id=, true) if ids_and_names.include?(r.friendly_id)}

    results

  end

  def validate_find_options(options) #:nodoc:#
    options.assert_valid_keys([:conditions, :include, :joins, :limit, :offset,
      :order, :select, :readonly, :group, :from, :lock, :having, :scope])
  end
end