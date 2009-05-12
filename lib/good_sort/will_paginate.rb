module GoodSort
  module WillPaginate
    def self.included(base)
      base.send :include, InstanceMethods
      base.alias_method_chain :will_paginate, :good_sort
    end

    module InstanceMethods
      def will_paginate_with_good_sort( collection = nil, options = {} )
        will_paginate_without_good_sort( collection, options.merge( :remote => @remote_options, :params => params ) )
      end
    end
  end
end

class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

  protected
  def page_link(page, text, attributes = {})
    _url = url_for(page)
    @template.link_to_remote(text, {:url => _url, :method => :get}.merge(@remote), { :href => _url })
  end
end

WillPaginate::ViewHelpers.pagination_options[:renderer] = 'RemoteLinkRenderer'
