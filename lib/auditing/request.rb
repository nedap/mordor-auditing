module Auditing
  class Request
    include Mordor::Resource

    attribute :url
    attribute :url_parts
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
        :url_parts    => url_parts,
        :method       => method,
        :at           => at
      }
    end

    def url=(url)
      self.url_parts = url_to_parts(url)
      @url = url
    end

    def modifications
      Modification.find_by_request(_id.to_s)
    end

    def url_parts=(parts)
      @url_parts = self.replace_params(parts)
    end

    def params=(params)
      @params = self.replace_params(params)
    end

    def self.find_by_url(url, partial = false)
      if partial
        Mordor::Collection.new(self, self.collection.find(:url => /.*#{url}.*/))
      else
        Mordor::Collection.new(self, self.collection.find(:url => url))
      end
    end

    def self.find_by_url_parts(params = {})
      parts_params = {}
      params.each do |key, value|
        parts_params["url_parts.#{key}"] = value
      end
      Mordor::Collection.new(self, self.collection.find(parts_params))
    end

    private

    def self.collection_name
      'audit_requests'
    end

    def url_to_parts(url)
      result = {}
      if url
        url.scan(/([\w|_]+)\/([\d|-]+)/).each do |key, value|
          key = key.gsub(/\W|\./, "_")
          result[key.to_sym] = value.match(/-/) ? value : value.to_i
        end
      end
      result
    end
  end
end
