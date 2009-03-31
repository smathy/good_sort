module GoodSort
  module WillPaginate
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.alias_method_chain :will_paginate, :good_sort
    end

    module InstanceMethods
      def will_paginate_with_good_sort( collection = nil, options = {} )
        will_paginate_without_good_sort( collection, options.merge( :remote => @remote_options, :params => params ) )
      end
    end
  end
end
