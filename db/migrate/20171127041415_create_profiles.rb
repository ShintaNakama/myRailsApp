class CreateProfiles < ActiveRecord::Migration[5.1]
  def change
    create_table :profiles do |t|
      t.string :lastNameKana
      t.string :firstNameKana
      t.date :birthDay
      t.string :bloodType
      t.string :sex

      t.timestamps
    end
  end
end
