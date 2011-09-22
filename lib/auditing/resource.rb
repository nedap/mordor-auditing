module Auditing
  module Resource
    attr_accessor :_id

    def self.included(base)
      base.extend(ClassMethods)
    end

    def replace_params(params)
      result = {}
      params.each do |key, value|
        value = replace_type(value)
        key = key.to_s.gsub(/^(\$)|\./, "_")
        result[key] = value
      end
      result
    end

    def replace_type(value)
      case value
      when Hash
        value = replace_params(value)
      when Date, DateTime
        value = value.to_time
      when BigDecimal
        value = value.to_f
      when Array
        value = value.map do |val|
          replace_type(val)
        end
      when Integer
      else
        value = value.to_s
      end
      value
    end

    def save
      insert_id = self.class.collection.insert(self.to_hash)
      self._id = insert_id
      insert_id != nil
    end

    def collection
      self.class.collection
    end

    module ClassMethods
      def collection
        connection.collection(self.collection_name)
      end

      def collection_name
        klassname = self.to_s.downcase.gsub(/[\/|.|::]/, '_')
        "#{klassname}s"
      end

      def get(id)
        new(collection.find_one(:_id => id))
      end

      def connection
        @connection ||= Auditing.connection
      end

      def find_by_id(id)
        get(id)
      end

      def find_by_day(day)
        case day
        when DateTime
          start = day.to_date.to_time
          end_of_day = (day.to_date + 1).to_time
        when Date
          start = day.to_time
          end_of_day = (day + 1).to_time
        when Time
          start = day.to_datetime.to_date.to_time
          end_of_day = (day.to_date + 1).to_datetime.to_date.to_time
        end
        cursor = collection.find(:at => {'$gte' => start, '$lt' => end_of_day})
        Collection.new(self, cursor)
      end

      def attribute(name)
        attr_accessor name

        class_eval <<-EOS, __FILE__, __LINE__
          def self.find_by_#{name}(value)
            Collection.new(self, collection.find(:#{name} => value))
          end
        EOS
      end
    end
  end
end
