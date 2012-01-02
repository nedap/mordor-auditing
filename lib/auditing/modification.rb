module Auditing
  class Modification
    include Mordor::Resource

    attribute :request_id, :index => true
    attribute :object_type, :index => true
    attribute :object_id, :index => true
    attribute :changes
    attribute :action
    attribute :at, :index => true
    attribute :timestamp, :timestamp => true, :index => true

    def request_id=(id)
      if id.is_a?(String) && id != ""
        id = BSON::ObjectId.from_string(id)
      end
      @request_id = id
    end

    def request
      Auditing::Request.find_by_id(request_id)
    end

    def request=(request)
      self.request_id = request._id
    end

    def self.find_by_request(id)
      find_by_request_id(id)
    end

    def self.find_by_request_id(id)
      if id.is_a?(String)
        id = BSON::ObjectId.from_string(id)
      end
      Mordor::Collection.new(self, self.collection.find(:request_id => id))
    end

    def to_hash
      h = super
      h[:request_id] = request_id
      h
    end

    def changes=(changes)
      @changes = replace_params(changes)
    end

    def self.collection_name
      'audit_modifications'
    end
  end
end
