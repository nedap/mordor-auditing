module Auditing
  class Modification
    include Resource

    attribute :request_id
    attribute :object_type
    attribute :object_id
    attribute :changes
    attribute :action
    attribute :at

    class << self
      alias_method :find_by_request, :find_by_request_id
    end

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def request_id=(id)
      if id.is_a?(BSON::ObjectId)
        @request_id = id.to_s
      else
        @request_id = id
      end
    end

    def request
      Auditing::Request.find_by_id(request_id)
    end

    def find_by_request_id(id)
      if id.is_a?(String)
        super(BSON::ObjectId.from_string(id))
      else
        super
      end
    end

    def to_hash
      hash = super
      hash.merge!(:request_id => request_id) if request_id
      hash
    end

    def changes=(changes)
      @changes = replace_params(changes)
    end

    def self.collection_name
      'audit_modifications'
    end
  end
end
