require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {foreign_key: "#{name.to_s.underscore}_id",
                class_name:  "#{name.to_s.camelcase}",
                primary_key: "id" }

    merged_opts = defaults.merge(options)

    @foreign_key = merged_opts[:foreign_key].to_sym
    @class_name  = merged_opts[:class_name]
    @primary_key = merged_opts[:primary_key].to_sym
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {foreign_key: "#{self_class_name.to_s.singularize.underscore}_id",
                class_name:  "#{name.to_s.singularize.camelcase}",
                primary_key: "id" }

    merged_opts = defaults.merge(options)

    @foreign_key = merged_opts[:foreign_key].to_sym
    @class_name  = merged_opts[:class_name]
    @primary_key = merged_opts[:primary_key].to_sym
    # ...
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})

    options = BelongsToOptions.new(name, options)
    define_method(name) do
      fk = self.send(options.foreign_key)
      mc = options.model_class
      pk = options.primary_key

      results = mc.where(pk => fk)
      results.nil? ? nil : results.first
    end

  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      fk = options.foreign_key
      mc = options.model_class
      pk = self.send(options.primary_key)

      results = mc.where(fk => pk)
      results.nil? ? [] : results
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
