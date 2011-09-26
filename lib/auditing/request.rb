module Auditing
  class Request
    include Resource

    attribute :url
    attribute :method
    attribute :params
    attribute :user_id, :finder_method => :find_by_user
    attribute :real_user_id
    attribute :at

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
      @params = self.replace_params(params)
    end

    def self.find_by_url(url, partial = false)
      if partial
        Collection.new(self, self.collection.find(:url => /.*#{url}.*/))
      else
        Collection.new(self, self.collection.find(:url => url))
      end
    end

    private

    def self.collection_name
      'audit_requests'
    end
  end
end
