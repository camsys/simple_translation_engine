require 'rake'
require 'active_record'

namespace :simple_translation_engine do

  desc "Create translation, translation_key, and locale tables"
  task :install => :environment do

    connection = ActiveRecord::Base.connection

    if !ActiveRecord::Base.connection.table_exists? 'translations'
      connection.create_table :translations do |t|
        t.integer :locale_id
        t.integer :translation_key_id
        t.text :value
        t.timestamps
      end
    end
    if !ActiveRecord::Base.connection.table_exists? 'translation_keys'
      connection.create_table :translation_keys do |t|
        t.string :name
        t.timestamps
      end
    end
    if !ActiveRecord::Base.connection.table_exists? 'locales'
      connection.create_table :locales do |t|
        t.string :name
        t.timestamps
      end
    end

    Rake::Task["db:schema:dump"].invoke

  end

end