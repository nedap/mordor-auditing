module Auditing
  module Resource

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def collection
        connection.collection(self.collection_name)
      end

      def collection_name
        self.to_s.pluralize
      end

      def get(id)
        new(collection.find_one(:_id => id))
      end

      def connection
        @connection ||= Auditing.connection
      end
    end
  end
end
