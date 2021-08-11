class AddCheckedToReferencedRegistration < ActiveRecord::Migration[6.1]
  def change
    add_column :referenced_registrations, :checked, :boolean, default: false
  end
  add_index :referenced_registrations, :checked
end
