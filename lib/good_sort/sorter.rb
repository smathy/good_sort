module GoodSort
  module Sorter
    def sort_fields; @@sort_fields ||= {}; end
    def sort_by(p)
      return unless p && p[:field] && p[:down]
      f = p[:field]
      unless options = sort_fields[f.to_sym]
        raise ArgumentError, "Requested field #{f} was not defined in #{class_name} for sorting"
      end
      options = options.dup
      options[:order] += ' DESC' unless p[:down].blank?
      options
    end
    protected
    def sort_on(*fields)
      fields.each do |f|

        if f.is_a? String or f.is_a? Symbol
          if self.columns_hash[f.to_s]
            sort_fields[f.to_sym] = { :order => f.to_s }
            next
          else
            # if it's not one of ours, we'll see if it's an association
            f = { f => :name }
          end
        end

        if f.is_a? Hash
          f.each do |k,v|
            ass = association_for( k )
            unless ass_has_attr( ass, v )
              raise ArgumentError, "belongs_to association #{k} does not have specified column #{v}"
            end
            sort_fields[k.to_sym] = { :order => ass_to_table(ass) + '.' + v.to_s, :joins => k.to_sym }
          end
          next
        end
        raise ArgumentError, "Unrecognized option to sort_by"
      end
    end
    private
    def association_for(k)
      ass = self.reflect_on_association(k.to_sym) and ass.belongs_to? or raise ArgumentError, "belongs_to association not found for #{k}"
      ass
    end
    def ass_has_attr(ass,v)
      ass.klass.column_names.find{|e|e==v.to_s}
    end
    def ass_to_table(ass)
      ass.class_name.tableize
    end
  end
end
