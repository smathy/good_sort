module GoodSort
  class << self
    def shwing
      require 'good_sort/view_helpers'
      ActionView::Base.send :include, ViewHelpers

      require 'good_sort/sorter'
      ActiveRecord::Base.send :extend, Sorter
    end
  end
end

GoodSort.shwing
