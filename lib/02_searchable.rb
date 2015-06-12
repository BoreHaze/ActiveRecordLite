require_relative 'db_connection'
require_relative '01_sql_object'
require_relative 'relation'

module Searchable
  def where(params)
    # where_line = params.keys.map{|attr| "#{attr} = ?"}.join(" AND ")
    # results = DBConnection.execute(<<-SQL, *params.values)
    #   SELECT
    #     *
    #   FROM
    #     #{self.table_name}
    #   WHERE
    #     #{where_line}
    # SQL
    #
    # results.map { |sql_obj| self.new(sql_obj) }

    Relation.new(self.class, params)

  end
end

class Relation
  def initialize(rel_class, initial_condition)
    @rel_class = rel_class
    @conditions = [initial_condition]
  end

  def where(condition)
    @conditions.push(condition)
  end

  def build_condition_string
    cond_string = ""
    first = true
    @conditions.each do  |col, val|
      first ? cond_string += "WHERE" : cond_string += "AND"
      cond_string += "#{col} = #{val}"
      first = false
    end

    cond_string
  end

  
end


class SQLObject
  extend Searchable
end
