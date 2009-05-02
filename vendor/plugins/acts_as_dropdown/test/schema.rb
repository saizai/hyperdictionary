ActiveRecord::Schema.define(:version => 0) do
  create_table :states, :force => true do |t|
    t.column :name,           :string
    t.column :abbreviation,   :string
  end

  create_table :statuses, :force => true do |t|
    t.column :status,         :string
    t.column :abbreviation,   :string
  end
end