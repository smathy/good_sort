Good Sort
=========

Hate not having _the right way_&trade; to do column sorting in list (collection)
views?  Well, fear not my dear friend, for good_sort has arrived.

It does Ajax for those with JS and regular links for those without.

It _just works_&trade; with `will_paginate`?

Installation
------------

### gem

To perform a system wide installation:

    gem source -a http://gems.github.com
    gem install JasonKing-good_sort

Then add it to your `config/environment.rb`:

    config.gem 'JasonKing-good_sort', :lib => 'good_sort'

### plugin

    script/plugin install git://github.com/JasonKing/good_sort.git

### git submodule

    git submodule add git://github.com/JasonKing/good_sort.git vendor/plugins/good_sort

Usage
-----

### app/models/author.rb
    sort_on :name, :updated_at

### app/controllers/site_controller.rb
    def index
      @authors = Author.all( Author.sort_by(params[:sort]) )

      if request.xhr?
        return render :partial => 'authors'
      end
    end

### app/views/site/index.html.erb
    <div id="authors">
      <%= render :partial => 'authors' %>
    </div>

### app/views/site/_authors.html.erb
    <table>
      <thead>
        <tr>
          <%
            sort_headers_for :author, %w{name ranking phone updated_at} do |header|
              "Last Changed" if header == 'updated_at'
            end
          %>
        </tr>
      </thead>
      <tbody>
        <% @authors.each do |author| -%>
        <tr>
          <td><%=h author.name %></td>
          <td><%=h author.ranking %></td>
          <td><%=h author.phone %></td>
          <td><%=h author.updated_at %></td>
        </tr>
        <% end -%>
      </tbody>
    </table>

That's simple enough isn't it?

The `sort_headers_for` helper will make a heading for each one of the elements
in the array you pass in - if it's one of the fields that you've set sorting on
in your model (using the `sort_on` class method).

Methods
-------

### ActiveRecord::Base.sort\_on( *args )

This is the class method that you use in your model in order to let `good_sort`
know which attributes of your model can be used to sort the collection.
Obviously these can't be virtual attributes because we're generating SQL here
(if you don't know what virtual attributes are then google is your friend).

As well as attributes in your model, you can also supply `belongs_to`
association names which will make `good_sort` sort your collection based on the
fields in a JOINed table.

    class Author < ActiveRecord::Base
      belongs_to :state
      sort_on :name, :updated_at, :state
    end

The convention is that this will use the `name` attribute of the associated
model, but if you want the sorting done using a different field then you can
just specify it using key => value style params, like so:

    class Author < ActiveRecord::Base
      belongs_to :state
      sort_on :name, :updated_at, :state => :long_name
    end

If you're confident that you know what you're doing, then you can also specify a string for the value of the associated attribute, in which case `good_sort` will just trust you and use this as the `ORDER BY` clause.  Make sure you qualify your field names with the join table name if there's any ambiguity.  Like so:

    class Author < ActiveRecord::Base
      belongs_to :state
      sort_on :name, :updated_at, :state => "COALESCE( states.long_name, states.short_name, '' )"
    end

There's also no requirement to cram it all in on one line, you can have multiple
`sort_on` declarations, and they will just be accumulated.

### ActiveRecord::Base.sort\_by( params[:sort] )

This produces a `:order` hash suitable to be merged into your `Model.find` (or
`Model.paginate`) parameters based on the `:field` and `:down` input parameters.

### ActionView::Base#sort\_headers\_for( model\_name, header\_array, options = {}, &block )

With no options, this will create `<th>` elements for each element of the
header_array, they will be given an id which, for the `name` field of our
`author` example would be `author_header_name`.  If it has sorting set for it
with `sort_on` in your model, then it will also be wrapped in a gracefully
degrading re-sorting ajaxified link which will replace the element with id of
pluralized model name, so for our author example it will replace the element
with the id of `"authors"` (it will also show/hide an element with id of
`"spinner"` during the request).  If the list is already sorted by that field,
then a class of either `"up"` or `"down"` will be added to the `<th>` element.

So, all of those things can be overridden.  The options you can pass in are as
follows:

 * **:spinner** - The id of the element to show/hide during the AJAX request, defaults to `:spinner`
 * **:tag** - The type of element to wrap your header links in, defaults to `:th`
 * **:header** - Options passed to the content_tag for the :tag wrapper.
  * No defaults, but :id is set to `<model>\_header\_<field>` and :class will have `"up"` or `"down"` added to it appropriately.
 * **:remote** - Options passed to `link\_to\_remote` as second arg, see the docs for `link\_to\_remote` for these options, defaults below:
  * **:update** - Defaults to the lower-case pluralized and underscored version of your model name - ie. model\_name.tablelize
  * **:before** - Defaults to showing the `:spinner` element (whatever you set that to, or `"spinner"` if you don't set it).
  * **:complete** - Defaults to hiding the `:spinner` element
  * **:method** - :get - you probably shouldn't change this
  * **:url** - No point in setting this, it is overridden with the link URL.
 * **:html** - Options pass to the `link\_to\_remote` as the third argument, see the docs for `link\_to\_remote` for these, defaults below:
  * **:title** - Defaults to "Sort by #{sort\_field\_tag}".  If you embed the sort\_field\_tag attribute in your string then that will be replaced with the field\_name.titlize for you, eg: :title => "Order by #{sort\_field\_tag}"  If you want anything fancier then you can override `sort\_header\_title` and do whatever you want.
  * **:html** - No point in setting this, it is overridden with the link URL.

Finally, if you pass a block, then it will be yielded to for each field in your
header\_array, and you can provide different text to be displayed for as many of
the headings as you like.

As long as you require `good_sort` after you've required `will_paginate` then
`good_sort` will override the `will_paginate` view helper to inject the params
needed to ensure that the page links will all know about the sorting column.
The only caveat is that the call to `will_paginate` needs to be **within** the
partial that is rendered by the AJAX call so that it is re-rendered when you
sort.
