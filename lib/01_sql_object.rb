require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    cols = DBConnection.execute2("SELECT * FROM #{self.table_name}")
    cols.first.map { |c| c.to_sym }
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}") do
        self.attributes[col.to_sym]
      end

      define_method("#{col}=") do |attr_val|
        self.attributes[col.to_sym] = attr_val
      end

    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.tableize
  end

  def self.all
    parse_all(DBConnection.execute("SELECT #{self.table_name}.* FROM #{self.table_name}"))
  end

  def self.parse_all(results)
    cats = []
    results.each do |sql_obj|
      cats << self.new(sql_obj)
    end
    cats
  end

  def self.find(id)
    #all.find { |obj| obj.id == id }
    found = DBConnection.execute("SELECT #{self.table_name}.* FROM #{self.table_name} WHERE id = #{id}")
    found.count == 1 ? self.new(found[0]) : nil
  end

  def initialize(params = {})
    params.each do |attr_str, attr_val|
      attr_name = attr_str.to_sym

      if !self.class.columns.include?(attr_name)
        raise "unknown attribute '#{attr_name}'"
      end

      self.send("#{attr_name}=", attr_val)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.class.columns.map {|c| self.send("#{c}")}
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(",")
    question_marks = (["?"] * cols.count).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id

  end

  def update

    set_line = self.class.columns.map {|attr| "#{attr} = ? "}.join(",")

    DBConnection.execute(<<-SQL, *attribute_values, self.id)
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL
  end

  def save
    id.nil? ? insert : update
  end
end
