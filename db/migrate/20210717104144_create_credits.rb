class CreateCredits < ActiveRecord::Migration[6.1]
  def change
    create_table :credits do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.float :amount

    end
  end
end
