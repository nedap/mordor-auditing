module Auditing
  class Modification
    include Resource

    attr_accessor :_id
    attr_accessor :request_id
    attr_accessor :object_type
    attr_accessor :object_id
    attr_accessor :changes
    attr_accessor :action
    attr_accessor :at

    def initialize(option = {})
      options.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def to_hash
      hash = {
        :object_type => object_type,
        :object_id => object_id,
        :changes => changes,
        :action => action,
        :at => at
      }
      hash.merge!(:request_id => request_id) if request_id
      hash
    end

    def changes=(changes)
      @changes = replace_params(changes)
    end

  end
end
