module GoodSort
  module ViewHelpers
    @@field_tag = '__FIELD__'
    def sort_field_tag; @@field_tag; end
    def sort_headers_for( m, h, options = {} )

      id = m.to_s.singularize
      m = m.to_s.classify
      c = m.constantize

      options.symbolize_keys!
      options[:spinner] ||= :spinner
      options[:tag] ||= :th

      options[:header] ||= {}
      options[:header].symbolize_keys!

      options[:remote] ||= {}
      options[:remote].symbolize_keys!
      options[:remote][:update] ||= m.tableize
      options[:remote][:before] = "$('#{options[:spinner]}').show()" unless options[:remote].has_key? :before
      options[:remote][:complete]  = "$('#{options[:spinner]}').hide()" unless options[:remote].has_key? :complete
      options[:remote][:method] ||= :get

      # save these for pagination calls later in the request
      @remote_options = options[:remote].dup

      options[:html] ||= {}
      options[:html].symbolize_keys!
      options[:html][:title] ||= "Sort by #{sort_field_tag}"

      sf = c.sort_fields
      logger.warn "GoodSort: #{m} has not had any sort_on fields set" if sf.nil?

      h.each do |f|
        options[:header][:id] = "#{id}_header_#{f}"

        text = yield(f) if block_given?
        text ||= f.to_s.titleize

        unless sf[f.to_sym]
          concat content_tag(options[:tag], text, options[:header])
          next
        end

        concat sort_header( f, text, options )
      end
    end

    def sort_header(f, text, options )
      params[:sort] ||= {}

      tag_options = options[:header].dup
      if params[:sort][:field] == f.to_s
        tag_options[:class] ||= ''
        (tag_options[:class] += params[:sort][:down].blank? ? ' up' : ' down' ).strip!
      end
      content_tag( options[:tag], sort_link(f, text, options), tag_options )
    end

    def sort_link(f, text, options)
      s = { :field => f, :down => params[:sort][:field] == f.to_s && params[:sort][:down].blank? ? true : nil }
      ps = params.merge( :sort => s, :page => nil )

      options[:remote][:url] = options[:html][:href] = url_for( :params => ps )
      title = sort_header_title( text, options)
      link_to_remote(text, options[:remote], options[:html].merge( :title => title))
    end

    def sort_header_title( field, options )
      options[:html][:title].gsub(sort_field_tag, field)
    end
  end
end
