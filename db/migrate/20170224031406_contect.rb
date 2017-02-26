class Contect < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :contact_phone, :text
  end
end
