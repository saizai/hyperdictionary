require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => "test:unit"

namespace :test do
  desc 'Test the polymorphic_include plugin.'
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'lib'
    t.pattern = 'test/unit/*_test.rb'
    t.verbose = true
  end

  Rake::TestTask.new(:expectation) do |t|
    t.libs << 'lib'
    t.pattern = 'test/expectation/*_test.rb'
    t.verbose = true
  end
end

desc 'Generate documentation for the polymorphic_include plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PolymorphicInclude'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
