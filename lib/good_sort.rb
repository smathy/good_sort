module GoodSort
  class << self
    def shwing
      require 'good_sort/view_helpers'
      ActionView::Base.send :include, ViewHelpers

      require 'good_sort/sorter'
      ActiveRecord::Base.send :include, Sorter

      if ActionView::Base.instance_methods.include? 'will_paginate'
        require 'good_sort/will_paginate'
        ActionView::Base.send :include, WillPaginate
      end
    end
  end
end

GoodSort.shwing
