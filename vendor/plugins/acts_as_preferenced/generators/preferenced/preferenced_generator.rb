class PreferencedGenerator < Rails::Generator::NamedBase

  def manifest
    record do |m|
      m.directory File.join('app/models', class_path)
      m.directory File.join('test/unit', class_path)
      
      m.template 'model.rb',
            File.join('app/models', class_path, "#{file_name}.rb")

      unless options[:skip_migration]
        m.migration_template 'migration.rb', 'db/migrate', :assigns => {
          :migration_name => "Create#{class_name.pluralize.gsub(/::/, '')}"
        }, :migration_file_name => "create_#{file_path.gsub(/\//, '_').pluralize}"
      end

    end
  end
  
  protected
  
    def banner
      "Usage: #{$0} preference Preference"
    end

end