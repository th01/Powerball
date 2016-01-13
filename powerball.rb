require 'sqlite3'

module GetPowerballCombos
  module Database
    def self.rm_existing_db
      %x(rm powerball.db)
    end

    def self.create_db
      @db = SQLite3::Database.new 'powerball.db'
    end

    def self.create_table
      db.execute <<-SQL
        CREATE TABLE numbers(
          id        INTEGER PRIMARY KEY AUTOINCREMENT,
          one       INT,
          two       INT,
          three     INT,
          four      INT,
          five      INT,
          powerball INT
        );
      SQL
    end

    def self.db
      @db
    end
  end

  Database.rm_existing_db
  Database.create_db
  Database.create_table
  DB              = Database.db
  BALLS           = (1..69).to_a
  POWERBALLS      = (1..26).to_a
  START           = Time.now
  INSERT_INTERVAL = 500

  def self.find_combos
    combos       = []
    counter      = 0
    last_counter = 0
    last_time    = START

    BALLS.each do |b1|
      BALLS[b1..-1].each do |b2|
        BALLS[b2..-1].each do |b3|
          BALLS[b3..-1].each do |b4|
            BALLS[b4..-1].each do |b5|
              POWERBALLS.each do |pb|
                combo = [b1, b2, b3, b4, b5, pb]
                combos << combo
                counter += 1
                if (counter % INSERT_INTERVAL).zero? || (b5 == BALLS.last && pb == POWERBALLS.last)
                  now = Time.now
                  insert_combos_into_db(combos)
                  combos = []
                  puts "#{string_number(counter)} combos processed at #{((counter - last_counter)/(now - last_time)).to_i} combos/s"
                  last_time    = now
                  last_counter = counter
                end
              end
            end
          end
        end
      end
    end
    puts "#{string_number(counter)} combos processed in #{Time.now - START} seconds"
  end

  private

  def self.insert_combos_into_db(combos)
    inserts = combos.map { |combo| "(#{combo.join(',')})" }.join(",\n")
    sql = <<-SQL
      INSERT INTO numbers (one, two, three, four, five, powerball)
      VALUES
      #{inserts};
    SQL
    DB.execute sql
  end

  def self.string_number(n)
    n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end
end


GetPowerballCombos.find_combos
