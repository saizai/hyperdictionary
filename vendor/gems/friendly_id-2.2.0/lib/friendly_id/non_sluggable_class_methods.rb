# encoding: utf-8

module FriendlyId::NonSluggableClassMethods

  include FriendlyId::Helpers

  protected

  def find_one(id_or_name, options) #:nodoc:#
    if id_or_name.is_a?(String)
      has_scope = friendly_id_options[:assume_scope] or options.has_key?(:scope) or id.include?(friendly_id_options[:separator])
      if has_scope # if it's not sluggable, we assume that the scope is a column name (and not something fancy like a method or association)
        scope = options.delete(:scope)
        scope, name = get_scoped_name(id_or_name) if !scope # derive it from the scoped ID
        result = send("find_by_#{ friendly_id_options[:column] }_and_#{friendly_id_options[:scope]}", name, scope, options)
      else
        result = send("find_by_#{ friendly_id_options[:column] }", id_or_name, options)
      end
      raise ActiveRecord::RecordNotFound if !result
      result.send(:found_using_friendly_id=, true)
    else
      result = super id_or_name, options
    end
    result
  end

  def find_some(ids_and_names, options) #:nodoc:#
    return super(ids_and_names, options) if ids_and_names.select{|x| x.is_a? String}.blank?
    
    scopable = friendly_id_options.has_key? :scope
    # if there's no scope specified... we don't assume it, because it's too ambiguous. Instead we don't select for scope. Can be made specific by using the prefix (e.g. ':Foo')
    has_scope = (options.has_key?(:scope) or ids_and_names.find{|x| x.is_a?(String) and x.include?(friendly_id_options[:separator])})
    scoped_find_options = {}
    if has_scope
      scope = options.delete(:scope) # if you pass :scope, you can't also use delimited names like 'Foo:Bar' ('cause that'd be a potential contradiction)
      if !scope
        # if at least one item has a scope, we use it
        scoped_names = ids_and_names.select{|x| x.is_a? String}.map{|x| get_scoped_name(x)}
        ids = ids_and_names.select{|x| !x.is_a? String }
        scopes = scoped_names.map{|x,y| x}.uniq
        names = scoped_names.map{|x,y| y}.uniq
        ids_and_names = names
        # E.g. if you search for: ['Foo', 'Bar:Qux'], then our search will actually return :Foo, Bar:Foo, :Qux, and Bar:Qux (if those all exist), but toss the extras
        # If we instead searched for "(name = 'Foo' AND scope = '') OR (name = 'Qux' AND scope = 'Bar')",
        #  it'd not be able to use indexes very well, which'd probably be more inefficient than a small number of extra returns
        scoped_find_options[:conditions] = ["#{friendly_id_options[:scope]} IN (?)", scopes] 
      else
        scoped_find_options[:conditions] = {friendly_id_options[:scope] => scope }
      end
    end
    
    results = with_scope :find => options do
      with_scope :find => scoped_find_options do
        find :all, :conditions => ["#{quoted_table_name}.#{primary_key} IN (?) OR #{friendly_id_options[:column].to_s} IN (?)",
          ids_and_names, ids_and_names]
        end
    end
    
    # dropping any excess items on the floor first
    if has_scope and defined?(scoped_names)
      scoped_names = scoped_names.map{|x,y| [x.downcase, y.downcase] } # ignore case for this
      results = results.select{|result| name = result.send(friendly_id_options[:column]).downcase
                                        scope = result.send(friendly_id_options[:scope]).downcase
                                        scoped_names.include?([ scope, name]) or ids.include?(result.id) }
    end
    
    expected = expected_size(defined?(scoped_names) ? scoped_names + ids : ids_and_names, options)
    if ((!scopable or has_scope) and results.size != expected) or (scopable and !has_scope and results.size < expected) # with scope unspecified there might be more
      raise ActiveRecord::RecordNotFound, "Couldn't find all #{ name.pluralize } with IDs (#{ ids_and_names * ', ' }) AND #{ sanitize_sql options[:conditions] } (found #{ results.size } results, but was looking for #{ expected })"
    end

    results.each {|r| r.send(:found_using_friendly_id=, true) if ids_and_names.include?(r.friendly_id)}

    results

  end

  def get_scoped_name delimited_name
      split_name = delimited_name.split(friendly_id_options[:separator])
      raise "Invalid name #{id} - has more than one #{friendly_id_options[:separator]}" if split_name.size > 2
      scope = split_name.size == 2 ? split_name[0] : ''
      name  = split_name.size == 2 ? split_name[1] : split_name[0]
      [scope, name]
  end

  def validate_find_options(options) #:nodoc:#
    options.assert_valid_keys([:conditions, :include, :joins, :limit, :offset,
      :order, :select, :readonly, :group, :from, :lock, :having, :scope])
  end
end