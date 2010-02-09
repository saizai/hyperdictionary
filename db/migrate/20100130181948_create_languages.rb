class CreateLanguages < ActiveRecord::Migration
  def self.up
    raise "don't run me yet"
    
    
    # This is total overkill for 99% of purposes.
    # But enh, might as well, since it's kinda ambiguous otherwise.
    # This implements all current ISO 639 standards.
    create_table :languages do |t|
      t.string :name, :limit => 150, :default => nil, :null => false # e.g. "Isthmus Zapotec"
      t.string :inverted_name, :limit => 150, :default => nil # e.g. "Zapotec, Isthmus"
      t.string :native_name, :limit => 150, :default => nil
      t.string :scope, :default => nil, :limit => 1 # I(ndividual), M(acrolanguage), S(pecial), C(ollection)
      t.string :language_type, :default => nil, :limit => 1 # A(ncient), C(onstructed), E(xtinct), H(istorical), L(iving), S(pecial), (en)D(angered)
      t.string :code_639_1, :default => nil, :limit => 2 # also the first part of 639.3
      t.string :code_639_2b, :default => nil, :limit => 3 # bibliographic
      t.string :code_639_2t, :default => nil, :limit => 3 # terminology
      t.string :code_639_3, :default => nil, :limit => 3
      t.string :macrolanguage, :limit => 3, :default => nil # 639.3 macrolanguage code
      t.string :retired, :limit => 1, :default => nil # code for retirement: C (change), D (duplicate), N (non-existent), S (split), M (merge)
      t.string :retired_to, :limit => 3, :default => nil #  in the cases of C, D, and M, the identifier to which all instances of this Id should be changed
      t.string :retired_reason, :limit => 300, :default => nil
      t.date :retired_date, :default => nil
      t.string :country_code, :limit => 2 # 3166-1
      t.boolean :google_translated # whether the google translate API supports auotranslation (and recognition) to & from this language and (at least) English
      
      t.timestamps
    end
    
    # And this implements all current ISO 3166 standards
    create_table :countires do |t|
      t.string :name, :limit => 150
      t.string :code_3166_1, :limit => 2 # ISO 3166.1 alpha-2. Oy. (e.g. DE = Germany)
      t.string :code_3166_2, :limit => 3 # ISO 3166.2 subdivision code (e.g. BW = Baden-Württemberg; full 3166.2 = DE-BW) 
      t.string :code_3166_3, :limit => 2 # ISO 3166.3 2 letter code for ex-countries (e.g. MM for Burma-now-Myanmar; full 3166.3 = BUMM, no dash)
      t.string :code_unlocode # United Nations Code for Ports and other Locations (e.g. DESTR = City of Stuttgart)
      t.boolean :tld # registed as an IANA TLD
    end
    
#    Language.import [:code, :name, :native_name]
  end

  def self.down
    drop_table :languages
  end
end
