class RemoveOrphanPins < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
      DELETE FROM pins
      WHERE issue_id NOT IN (SELECT id FROM issues)
         OR user_id NOT IN (SELECT id FROM users)
    SQL
  end

  def down
    # Orphan rows cannot be restored.
  end
end
