require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)

    define_method(name) do

      through_options = self.class.assoc_options[through_name]
      source_options  = through_options.model_class.assoc_options[source_name]

      source_mc = source_options.table_name   #SELECT/ JOIN
      through_mc = through_options.table_name #FROM

      through_pk = through_options.primary_key #ON this = ...
      source_pk = source_options.primary_key #this; WHERE this =...
      source_fk = source_options.foreign_key

      through_fk = self.send(through_options.foreign_key) #this

      result = DBConnection.execute(<<-SQL)
        SELECT
          #{source_mc}.*
        FROM
          #{through_mc}
        JOIN
          #{source_mc}
        ON
          #{through_mc}.#{source_fk} = #{source_mc}.#{source_pk}
        WHERE
          #{through_mc}.#{through_pk} = #{through_fk}
      SQL

      result.nil? ? nil : source_options.model_class.parse_all(result).first


    end

  end
end
