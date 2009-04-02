require 'test_helper'
require 'good_sort/view_helpers'
require 'active_support'
require 'action_view'

class Foo; end
class Logger; end
class GoodSortViewHelperTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include GoodSort::ViewHelpers

  def concat(a); @output << a; end
  def params; @p ||= {}; end
  def logger; @l ||= Logger.new; end

  def setup
    @output = ''
    Foo.stubs(:sort_fields).returns( :name => true, :age => true )
  end

  def test_default_headers
    %w{name age}.each do |f|
      expects(:url_for).returns( "/foo" )
      expects(:link_to_remote).with(
        f.titleize,
        {
          :update => 'foos',
          :method => :get,
          :url => "/foo",
          :complete => %q{$('spinner').hide()},
          :before => %q{$('spinner').show()}
        },
        {
          :href => "/foo",
          :title => "Sort by #{f.titleize}"
        }).returns( "<link>#{f}</link>" )
    end

    sort_headers_for :foo, %w{name age bar}
    assert_equal %q{<th id="foo_header_name"><link>name</link></th><th id="foo_header_age"><link>age</link></th><th id="foo_header_bar">Bar</th>},
      @output
  end

  def test_some_options
    spinner_name = :foobar
    update_id = :sesame
    %w{name age}.each do |f|
      expects(:url_for).returns( "/foo" )
      expects(:link_to_remote).with(
        f.titleize,
        {
          :update => update_id,
          :method => :get,
          :url => "/foo",
          :complete => %Q{$('#{spinner_name}').hide()},
          :before => %Q{$('#{spinner_name}').show()}
        },
        {
          :class => :horton,
          :href => "/foo",
          :title => "Sort by #{f.titleize}"
        }).returns( "<link>#{f}</link>" )
    end

    bar_text = 'Big bar'
    sort_headers_for :foo, %w{name age bar}, :spinner => spinner_name, :tag => :td, :remote => { :update => update_id }, :html => { :class => :horton } do |f|
      bar_text if f == 'bar'
    end
    assert_equal %Q{<td id="foo_header_name"><link>name</link></td><td id="foo_header_age"><link>age</link></td><td id="foo_header_bar">#{bar_text}</td>},
      @output
  end

  def test_sorting_name_up
    params[:sort] ||= {}
    params[:sort][:field] = 'name'
    params[:sort][:down] = ''

    p = { :name => true, :age => nil }

    %w{name age}.each do |f|
      expects(:url_for).with(:params => {:sort => {:field => f, :down => p[f.to_sym]}, :page => nil}).returns( "/foo" )
      expects(:link_to_remote).with(
        f.titleize,
        {
          :update => 'foos',
          :method => :get,
          :url => "/foo",
          :complete => %q{$('spinner').hide()},
          :before => %q{$('spinner').show()}
        },
        {
          :href => "/foo",
          :title => "Sort by #{f.titleize}"
        }).returns( "<link>#{f}</link>" )
    end

    sort_headers_for :foo, %w{name age}
    assert_equal %q{<th class="up" id="foo_header_name"><link>name</link></th><th id="foo_header_age"><link>age</link></th>},
      @output
  end

  def test_sorting_name_down
    params[:sort] ||= {}
    params[:sort][:field] = 'name'
    params[:sort][:down] = 'true'

    p = { :name => nil, :age => nil }

    %w{name age}.each do |f|
      expects(:url_for).with(:params => {:sort => {:field => f, :down => p[f.to_sym]}, :page => nil}).returns( "/foo" )
      expects(:link_to_remote).with(
        f.titleize,
        {
          :update => 'foos',
          :method => :get,
          :url => "/foo",
          :complete => %q{$('spinner').hide()},
          :before => %q{$('spinner').show()}
        },
        {
          :href => "/foo",
          :title => "Sort by #{f.titleize}"
        }).returns( "<link>#{f}</link>" )
    end

    sort_headers_for :foo, %w{name age}
    assert_equal %q{<th class="down" id="foo_header_name"><link>name</link></th><th id="foo_header_age"><link>age</link></th>},
      @output
  end

  def test_sorting_age_up
    params[:sort] ||= {}
    params[:sort][:field] = 'age'
    params[:sort][:down] = ''

    p = { :name => nil, :age => true }

    %w{name age}.each do |f|
      expects(:url_for).with(:params => {:sort => {:field => f, :down => p[f.to_sym]}, :page => nil}).returns( "/foo" )
      expects(:link_to_remote).with(
        f.titleize,
        {
          :update => 'foos',
          :method => :get,
          :url => "/foo",
          :complete => %q{$('spinner').hide()},
          :before => %q{$('spinner').show()}
        },
        {
          :href => "/foo",
          :title => "Sort by #{f.titleize}"
        }).returns( "<link>#{f}</link>" )
    end

    sort_headers_for :foo, %w{name age}
    assert_equal %q{<th id="foo_header_name"><link>name</link></th><th class="up" id="foo_header_age"><link>age</link></th>},
      @output
  end
end
