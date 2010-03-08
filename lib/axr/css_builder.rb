module AjaxfulRating # :nodoc:
  class CSSBuilder
    attr_reader :rules
    
    def initialize
      @rules = {}
    end
    
    def rule(selector, attrs)        
      @rules[selector] = self.class.stringify_properties(attrs) unless @rules.has_key?(selector)
    end
    
    def to_css
      css = ''
      @rules.each do |key, value|
        css << "#{key} {#{value}}\n"
      end
      css
    end
    
    def self.stringify_properties(properties)
      css = ''
      properties.each do |key, value|
        value = value.is_a?(Fixnum) || value.is_a?(Float) ? "#{value}px" : value
        css << "#{key.to_s.underscore.dasherize}: #{value}; "
      end
      css
    end
  end
end
