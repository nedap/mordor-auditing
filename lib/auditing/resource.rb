module Auditing
  module Resource
    def collection
      connection.collection(collection_name)
    end

    def collection_name
      self.class.to_s.pluralize
    end

    protected
    def connection
      @connection ||= Audited.connection
    end
  end
end
