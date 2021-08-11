class CreateReferrals < ActiveRecord::Migration[6.1]
  def change
    create_table :referrals do |t|
      t.string :code, null: false, index: { unique: true }
      t.references :user, null: false, index: { unique: true }

    end
  end
end
