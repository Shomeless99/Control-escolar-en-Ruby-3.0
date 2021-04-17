#!/usr/bin/ruby

require 'sqlite3'

def insert_user(user, password)
    begin
        
        # Open a database
        db = SQLite3::Database.new "test.db"

        # Execute a few inserts
        {
            user => password
        }.each do |pair|
            db.execute "insert into users values ( ?, ? )", pair
        end
        return true
        
    rescue SQLite3::Exception => e 
        
        puts "Exception occurred"
        puts e
        return false
        
    ensure
        db.close if db
    end
end

#insert_user("pedro", "cam")