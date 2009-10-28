class CreateBadges < ActiveRecord::Migration
  def self.up
    create_table :badge_sets do |t|
      t.string :name
      t.boolean :public, :default => true, :null => false
    end
    
    BadgeSet.import [:name], [
      ["Early adopters"],
      ["Fans"],
      ["Moderators"],
      ["Subscribers"],
      ["Bug reporters"],
      ["Tiger team members"],
      ["Recruiters"]
    ]
    
    create_table :badges do |t|
      t.string :name, :description, :default => nil, :null => false
      t.integer :badge_set_id, :level, :default => nil, :null => false
      t.boolean :public, :default => true, :null => false
      t.integer :badgings_count, :default => 0, :null => false
      
      t.timestamps
    end
    
    Badge.import [:badgeset_id, :level, :name, :description], [
      [1, 3, 'Alpha user', "Started using #{APP_NAME} from the very beginning"],
      [1, 2, 'Beta user', "Started using #{APP_NAME} during the beta test"],
      [1, 1, 'Early adopter', "Started using #{APP_NAME} within the first 4 months"], # TODO: make this time period be sensible
      [2, 4, 'Addict', "Used #{APP_NAME} for at least 540 hours"],
      [2, 3, 'Devotee', "Used #{APP_NAME} for at least 180 hours"],
      [2, 2, 'Enthusiast', "Used #{APP_NAME} for at least 60 hours"],
      [2, 1, 'Fan', "Used #{APP_NAME} for at least 20 hours"],
      [3, 4, 'Coder', "Wrote #{APP_NAME} and has root access"],
      [3, 3, 'Admin', "Runs #{APP_NAME} and has access to admin power tools"],
      [3, 2, 'Steward', "Helps #{APP_NAME} moderators and moderates across groups"],
      [3, 1, 'Moderator', "Helps guide at least one group on #{APP_NAME}"],
      [4, 4, 'Sponsor', "Provided major financial support to #{APP_NAME}"],
      [4, 3, 'Supporter', ""],
      [4, 2, 'Patron', ""],
      [4, 1, 'Subscriber', ""],
      [5, 4, 'White hat', "Helped #{APP_NAME} admins fix at least 30 bugs"],
      [5, 3, 'QA team leader', "Helped #{APP_NAME} admins fix at least 20 bugs"],
      [5, 2, 'QA team member', "Helped #{APP_NAME} admins fix at least 10 bugs"],
      [5, 1, 'Bug reporter', "Helped #{APP_NAME} admins fix at least 1 bug"],
      [6, 4, 'Tiger team leader', "Discovered and reported 3 security vulnerabilities in #{APP_NAME}"],
      [6, 3, 'Sr. tiger team member', "Discovered and reported 2 security vulnerabilities in #{APP_NAME}"],
      [6, 2, 'Tiger team member', "Discovered and reported a security vulnerability in #{APP_NAME}"],
      [7, 4, 'Master recruiter', "Got at least 50 new people to join #{APP_NAME}"],
      [7, 3, 'Sr. recruiter', "Got at least 20 new people to join #{APP_NAME}"],
      [7, 2, 'Recruiter', "Got at least 10 new people to join #{APP_NAME}"],
      [7, 1, 'Jr. recruiter', "Got at least 2 new people to join #{APP_NAME}"],
      
    ]
  end

  def self.down
    drop_table :badges
    drop_talbe :badge_sets
  end
end
