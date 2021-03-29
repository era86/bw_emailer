class CreateEmailMessages < ActiveRecord::Migration[6.1]
  def change
    create_table :email_messages do |t|
      t.string :to
      t.string :to_name
      t.string :from
      t.string :from_name
      t.string :subject
      t.text :body
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
