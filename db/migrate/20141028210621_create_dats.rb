class CreateDats < ActiveRecord::Migration
  def change
    create_table :dats do |t|

      t.timestamps
    end
  end
end
