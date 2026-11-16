class NormalizeProductPermalinks < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE products SET permalink = LOWER(permalink) WHERE permalink IS NOT NULL"
  end

  def down
    raise ActiveRecord::IrreversibleMigration,
          "Cannot restore original permalink capitalization"
  end
end
