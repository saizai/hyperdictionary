$LOAD_PATH.unshift << ENV['ACTIVERECORD_PATH'] unless ENV['ACTIVERECORD_PATH'].nil?

require 'rubygems'
require 'test/unit'
require 'active_record'


log_path = File.join(File.dirname(__FILE__), '..', 'log')
db_path = File.join(File.dirname(__FILE__), '..', 'db')

[log_path, db_path].each { |dir| FileUtils.mkdir_p dir }

ActiveRecord::Base.logger = Logger.new(File.join(log_path, "debug.log"))

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => File.join(db_path, 'test.sqlite3')
)

ActiveRecord::Schema.define do
  create_table "mothers", :force => true do |t|
    t.column "name", :string
  end

  create_table "fathers", :force => true do |t|
    t.column "name", :string
  end

  create_table "children", :force => true do |t|
    t.column "parent_type", :string
    t.column "parent_id", :integer
    t.column "toy_id", :integer
    t.column "name", :string
  end

  create_table "pets", :force => true do |t|
    t.column "owner_type", :string
    t.column "owner_id", :integer
    t.column "name", :string
  end

  create_table "toys", :force => true do |t|
    t.column "name", :string
  end
end

class Mother < ActiveRecord::Base
  has_many :children, :as => :parent
end

class Father < ActiveRecord::Base
  has_many :children, :as => :parent
end

class Child < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :toy
end

class Toy < ActiveRecord::Base
  has_one :child
end

