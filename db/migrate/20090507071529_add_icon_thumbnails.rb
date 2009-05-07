class AddIconThumbnails < ActiveRecord::Migration
  def self.up
    Asset.find_each(:batch_size => 5){|asset| asset.save} # Trigger thumbnail creation
  end

  def self.down
    # Nothing to (un)do
  end
end
