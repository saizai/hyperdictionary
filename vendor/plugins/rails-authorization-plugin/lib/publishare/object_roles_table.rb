require File.dirname(__FILE__) + '/exceptions'
require File.dirname(__FILE__) + '/identity'

module Authorization
  module ObjectRolesTable

    module UserExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorized_user(roles_relationship_opts = {})
          has_many :roles_users, roles_relationship_opts.merge(:dependent => :delete_all)
          has_many :roles, :through => :roles_users
          include Authorization::ObjectRolesTable::UserExtensions::InstanceMethods
          include Authorization::Identity::UserExtensions::InstanceMethods   # Provides all kinds of dynamic sugar via method_missing
        end
      end

      module InstanceMethods
        # If roles aren't explicitly defined in user class then check roles table
        def has_role?( role_name, authorizable_obj = nil )
          if authorizable_obj.nil?
            !! roles_by_name( role_name )
          else
            return authorizable_obj == self if role_name == 'self'
            !! roles_for(authorizable_obj, role_name)
          end
        end
        
        def has_role( role_name, authorizable_obj = nil )
          role = get_or_create_role( role_name, authorizable_obj )
          add_role(role) if role and not has_role? role_name, authorizable_obj
        end
        
        def has_no_role( role_name, authorizable_obj = nil  )
          role =  get_role( role_name, authorizable_obj )
          remove_role role
          delete_role_if_empty( role )
        end
        
        def has_roles_for?( authorizable_obj )
          !! roles_for(authorizable_obj)
        end
        alias :has_role_for? :has_roles_for?

        def roles_for( authorizable_obj, role_name = nil )
          x = roles.find :all, :conditions => roles_for_conditions(authorizable_obj, role_name)          
          x.empty? ? nil : x
        end
        
        def has_no_roles_for(authorizable_obj = nil)Z
          old_roles = roles_for(authorizable_obj).dup
          remove_roles_for authorizable_obj
          old_roles.each { |role| delete_role_if_empty( role ) }
        end
        
        def has_no_roles
          old_roles = roles.dup
          remove_all_roles
          old_roles.each { |role| delete_role_if_empty( role ) }
        end
        
        def authorizables_for( authorizable_class )
          unless authorizable_class.is_a? Class
            raise CannotGetAuthorizables, "Invalid argument: '#{authorizable_class}'. You must provide a class here."
          end
          begin
            authorizable_class.find(
              roles_for(authorizable_class.base_class).map(&:authorizable_id).uniq
            )
          rescue ActiveRecord::RecordNotFound
            []
          end
        end

        private
        
        def remove_role role
          roles.delete role
        end
        
        def remove_all_roles
          roles.destroy_all
        end
        
        def add_role role
          roles << role
        end
        
        def remove_roles_for authorizable_obj
          roles_for(authorizable_obj).destroy_all
        end
        
        def roles_by_name role_name
          roles.find_by_name( role_name )
        end

        def get_role( role_name, authorizable_obj )
          if authorizable_obj.is_a? Class
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id IS NULL', role_name, authorizable_obj.to_s ] )
          elsif authorizable_obj
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type = ? and authorizable_id = ?',
                                        role_name, authorizable_obj.class.base_class.to_s, authorizable_obj.id ] )
          else
            Role.find( :first,
                       :conditions => [ 'name = ? and authorizable_type IS NULL and authorizable_id IS NULL', role_name ] )
          end
        end
        
        def get_or_create_role role_name, authorizable_obj
          role = get_role( role_name, authorizable_obj )
          role ||= if authorizable_obj.is_a? Class
            role = Role.create( :name => role_name, :authorizable_type => authorizable_obj.to_s )
          elsif authorizable_obj
            role = Role.create( :name => role_name, :authorizable => authorizable_obj )
          else
            role = Role.create( :name => role_name )
          end
        end

        def delete_role_if_empty( role )
          role.destroy if role && role.roles_users.count == 0
        end

        def roles_for_conditions authorizable_obj, role_name = nil
          conditions = ['roles_users.user_id IS NULL']
          if authorizable_obj.is_a? Class
            conditions[0] <<  ' and authorizable_type = ?'
            conditions << authorizable_obj.to_s
          elsif authorizable_obj
            conditions[0] << ' and authorizable_type = ? and authorizable_id = ?'
            conditions += [authorizable_obj.class.base_class.to_s, authorizable_obj.id]
          else
            conditions[0] << ' and authorizable_type IS NULL'
          end
          
          if role_name
            conditions[0] << ' and roles.name = ?'
            conditions << role_name
          end
          conditions
        end
        
      end # InstanceMethods
    end # UserExtensions
    
    module ModelExtensions
      def self.included( recipient )
        recipient.extend( ClassMethods )
      end

      module ClassMethods
        def acts_as_authorizable
          has_many :accepted_roles, :as => :authorizable, :class_name => 'Role'

          has_many :users, :finder_sql => 'SELECT DISTINCT users.* FROM users INNER JOIN roles_users ON user_id = users.id INNER JOIN roles ON roles.id = role_id WHERE authorizable_type = \'#{self.class.base_class.to_s}\' AND authorizable_id = #{id}', :counter_sql => 'SELECT COUNT(DISTINCT users.id) FROM users INNER JOIN roles_users ON user_id = users.id INNER JOIN roles ON roles.id = role_id WHERE authorizable_type = \'#{self.class.base_class.to_s}\' AND authorizable_id = #{id}', :readonly => true

          before_destroy :remove_user_roles

          def accepts_role?( role_name, user )
            (user || AnonUser).has_role? role_name, self
          end

          def accepts_role( role_name, user )
            (user || AnonUser).has_role role_name, self
          end

          def accepts_no_role( role_name, user )
            (user || AnonUser).has_no_role role_name, self
          end

          def accepts_roles_by?( user )
            (user || AnonUser).has_roles_for? self
          end
          alias :accepts_role_by? :accepts_roles_by?

          def accepted_roles_by( user )
            (user || AnonUser).roles_for self
          end

          def authorizables_by( user )
            (user || AnonUser).authorizables_for self
          end

          include Authorization::ObjectRolesTable::ModelExtensions::InstanceMethods
          include Authorization::Identity::ModelExtensions::InstanceMethods   # Provides all kinds of dynamic sugar via method_missing
        end
      end

      module InstanceMethods
        # If roles aren't overriden in model then check roles table
        def accepts_role?( role_name, user )
          (user || AnonUser).has_role? role_name, self
        end

        def accepts_role( role_name, user )
          (user || AnonUser).has_role role_name, self
        end

        def accepts_no_role( role_name, user )
          (user || AnonUser).has_no_role role_name, self
        end

        def accepts_roles_by?( user )
          (user || AnonUser).has_roles_for? self
        end
        alias :accepts_role_by? :accepts_roles_by?

        def accepted_roles_by( user )
          (user || AnonUser).roles_for self
        end

        private

        def remove_user_roles
          self.accepted_roles.each do |role|
            role.roles_users.delete_all
            role.destroy
          end
        end

      end
    end # ModelExtensions

  end # ObjectRolesTable
end # Authorization

# This is a bit of a kludge, but it works.
class AnonUser
  # Use the normal stuff an authorized user would have
  extend Authorization::ObjectRolesTable::UserExtensions::InstanceMethods
  extend Authorization::Identity::UserExtensions::InstanceMethods
  
  class << self 
    # And override the ones that call self, 'cause getting a fake self.roles that works like a real association is a major pain
    def roles_for( authorizable_obj, role_name = nil )
      x = Role.find :all, :conditions => roles_for_conditions(authorizable_obj, role_name), :joins => :roles_users
      x.empty? ? nil : x
    end
  
    private 
    
    def roles_by_name role_name
      x = Role.find :all, :conditions => ["roles_users.user_id IS NULL and name = ?", role_name], :joins => :roles_users
      x.empty? ? nil : x
    end
    
    def roles
      x = Role.find :all, :conditions => "roles_users.user_id IS NULL", :joins => :roles_users
      x.empty? ? nil : x
    end
    
    def add_role role
      RolesUser.create(:user_id => nil, :role_id => role.id) if role
    end
    
    def remove_role role
      RolesUser.delete_all ['user_id IS NULL and role_id = ?', role.id] if role
    end
    
    def remove_roles_for authorizable_obj
      role_ids = roles_for(authorizable_obj).map(&:id)
      RolesUser.delete_all ['user_id IS NULL and role_id IN (?)', role_ids] unless role_ids.empty?
    end
    
    def remove_all_roles
      RolesUser.delete_all ['user_id IS NULL']
    end
  end # << self
end # AnonUser
