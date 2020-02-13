# frozen_string_literal: true

# Convert a Hash with values of various Puppet data types to a String
# compatible with NRPE .cfg files.
Puppet::Functions.create_function(:'nrpe::hash2nrpe') do
  dispatch :hash2nrpe do
    param 'Hash', :object
    return_type 'String'
  end

  def hash2nrpe(object)
    result = {}

    unless object.is_a?(Hash)
      raise(Puppet::ParseError, 'nrpe::hash2nrpe(): Requires Hash to work with')
    end

    call_function('delete_undef_values',object).each do |k, v|
      case v.class.to_s
      when 'Array' then result[k] = v.join(',')
      when 'TrueClass', 'FalseClass' then result[k] = v ? '1' : '0'
      else result[k] = call_function('shellquote',v.to_s)
      end
    end

    return result.sort.to_h.map { |k, v| "#{k}=#{v}" }.join("\n")
  end
end
