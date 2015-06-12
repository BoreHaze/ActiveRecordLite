require_relative 'db_connection'
require_relative '01_sql_object'

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

    Relation.new(self, params)

  end
end

class Relation
  def initialize(rel_class, initial_condition)
    @rel_class = rel_class.to_s.downcase + "s"
    @conditions = [initial_condition]
  end

  def where(condition)
    @conditions.push(condition)
  end

  def build_condition_string
    cond_string = ""
    first = true
    @conditions.each do |cond|
      col = cond.keys[0]
      val = cond.values[0]

      first ? cond_string += "WHERE " : cond_string += "AND "
        if val.is_a?(String)
          cond_string += "#{col} = '#{val}' "
        else
          cond_string += "#{col} = #{val} "
        end
      first = false
    end

    cond_string
  end

  def evaluate
    results = DBConnection.execute("SELECT * FROM #{@rel_class} #{build_condition_string}")
    # results.map { |sql_obj| @rel_class.new(sql_obj) }
    if results.count == 0
      []
    elsif results.count == 1
      @rel_class.new(results[0])
    else
      results
    end
  end

  def first
    @rel_class.new(evaluate.first)
  end

  def length
    evaluate.length
  end

  def [](pos)
    evaluate[pos]
  end
end


class SQLObject
  extend Searchable
end
