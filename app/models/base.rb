# frozen_string_literal: true

require 'pstore'

# Base model for all models
class Base
  DB_FILE = ENV.fetch('DB_FILE') { File.expand_path('../../db.pstore', __dir__) }

  # Class-level methods for database operations.
  # Extended into Base to provide class methods like find, all, save, etc.
  module ClassMethods
    # Find a record by ID
    #
    def find(id)
      db.transaction(true) do
        db[derive_db_id(self.name, id)]
      end
    end

    # Returns all records for this model
    #
    def all
      db.transaction(true) do
        ids = extract_model_ids(db)
        ids.map { |key| db[key] }
      end
    end

    # Store a product in the DB
    #
    def save(object)
      db_id = derive_db_id(object.class.name, object.id)
      db.transaction do
        db[db_id] = object
      end
    end

    # Scoped by class, to auto-increment the product IDs
    #
    def next_available_id
      last_id = all_ids.map do |key|
        key.sub("#{self.name}_", '').to_i
      end.max.to_i

      last_id + 1
    end

    def last_record(model_name = self.name)
      db.transaction(true) do
        ids = extract_model_ids(db, model_name)
        db[ids.last] if ids.any?
      end
    end

    private

    # Access to the PStore binary file for products
    #
    def db
      @db ||= PStore.new(DB_FILE)
    end

    # Scoped by class, so that different model classes
    # can have the same numerical product IDs
    #
    def derive_db_id(model_name, obj_id)
      "#{model_name}_#{obj_id}"
    end

    # All the product IDs for this model
    #
    def all_ids
      db.transaction(true) do |db|
        extract_model_ids(db)
      end
    end

    # Get all the PStore 'DB' IDs
    # scoped for the current class or a specific model name
    #
    def extract_model_ids(store, model_name = self.name)
      store.roots.select do |key|
        key.start_with?(model_name)
      end
    end
  end
  extend ClassMethods

  def save
    ensure_presence_of_id
    self.class.save(self)
  end

  private

  def ensure_presence_of_id
    self.id ||= self.class.next_available_id
  end
end
