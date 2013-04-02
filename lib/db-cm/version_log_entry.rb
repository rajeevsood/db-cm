module Db
  module Cm
    class VersionLogEntry
      attr_reader :migration_id, :applied_at, :description, :already_run

      def initialize(migration_id, applied_at, description, already_run)
        @migration_id = migration_id
        @applied_at = applied_at
        @description = description
        @already_run = already_run
      end

      alias_method :already_run?, :already_run

      def to_s
        "<#{migration_id}, #{applied_at}, #{description}>"
      end
    end
  end
end