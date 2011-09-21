module Auditing
  class Request
    include Resource

    attr_accessor :_id
    attr_accessor :url
    attr_accessor :method
    attr_accessor :params
    attr_accessor :user_id
    attr_accessor :real_user_id
    attr_accessor :at

    def initialize(options = {})
      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def to_hash
      {
        :user_id      => user_id,
        :real_user_id => real_user_id,
        :params       => params,
        :url          => url,
        :method       => method,
        :at           => at
      }
    end

    def modifications
      Modification.find_by_request(_id.to_s)
    end

    def params=(params)
      @params = replace_params(params)
    end

    def self.get(id)
      new(collection.find_one(:_id => id))
    end

    private

    def collection_name
      'audit_requests'
    end
  end
end
