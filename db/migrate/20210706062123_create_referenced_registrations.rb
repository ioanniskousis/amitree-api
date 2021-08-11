class CreateReferencedRegistrations < ActiveRecord::Migration[6.1]
  def change
    create_table :referenced_registrations do |t|
      t.references :referer, class: :user, null: false, foreign_key: {to_table: :users}
      t.references :user, null: false, foreign_key: true

    end
  end
end
