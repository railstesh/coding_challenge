class AddKeyInfoToTools < ActiveRecord::Migration[6.0]
  def change
    add_column :tools, :key_info, :jsonb, default: {}
  end
end
