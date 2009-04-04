ActiveRecord::Schema.define(:version => 1) do
  create_table :preferences, :force => true do |t|
    t.column :preferrer_id,    :integer,               :null => false
    t.column :preferrer_type,  :string, :limit => 128, :null => false
    t.column :preferred_id,    :integer
    t.column :preferred_type,  :string,                :null => false
    t.column :name,            :string, :limit => 128, :null => false
    t.column :value,           :text
  end

  create_table :users, :force => true do |t|
    t.column :login, :string, :null => false
  end
end
