require 'sqlite3'

%x(rm powerball.db)

DB = SQLite3::Database.new 'powerball.db'

result = DB.execute <<-SQL
  CREATE TABLE numbers (
    one       INT,
    two       INT,
    three     INT,
    four      INT,
    five      INT,
    powerball INT
  );
SQL

# (one, two, three, four, five, powerball)

def insert_combs_into_db(combos)
  inserts = combos.map { |combo| "(#{combo.join(',')})" }.join(",\n")
  sql = <<-SQL
    INSERT INTO numbers VALUES
    #{inserts};
  SQL
  DB.execute sql
end

def string_number(n)
  n.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
end

BALLS           = (1..69).to_a
POWERBALLS      = (1..26).to_a
START           = Time.now
INSERT_INTERVAL = 500
last            = START
counter         = 0
combos          = []

BALLS.each do |b1|
  BALLS[b1..-1].each do |b2|
    BALLS[b2..-1].each do |b3|
      BALLS[b3..-1].each do |b4|
        BALLS[b4..-1].each do |b5|
          POWERBALLS.each do |pb|
            combo = [b1, b2, b3, b4, b5, pb]
            combos << combo
            counter += 1
            if (counter % INSERT_INTERVAL).zero?
              now = Time.now
              insert_combs_into_db(combos)
              combos = []
              puts "#{string_number(counter)} combos processed at #{(INSERT_INTERVAL/(now - last)).to_i} combos/s"
              last = now
            end
          end
        end
      end
    end
  end
end

puts counter
