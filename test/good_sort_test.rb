require 'test_helper'
require 'good_sort/sorter'
require 'active_support'

class GoodSortSorterTest < Test::Unit::TestCase
  include GoodSort::Sorter
  def columns_hash; { 'foo' => true, 'bar' => true }; end
  def class_name; "foobar"; end

  def reflect_on_association(a)
    ass = mock()
    ass.stubs(:belongs_to?).returns(a.to_sym == :ass_exist)

    ass.stubs(:class_name).returns('ass_exists')

    ass_klass = mock()
    ass_klass.stubs(:column_names).returns( %w{name last_name} )

    ass.stubs(:klass).returns(ass_klass)

    ass
  end

  def test_sort_on_our_attributes
    sort_on :foo, :bar
    assert_equal 2, sort_fields.length
    assert_equal( { :order => 'foo' }, sort_fields[:foo])
    assert_equal( { :order => 'bar' }, sort_fields[:bar])
  end

  def test_association_sort_fields
    sort_on :ass_exist => :last_name
    assert_equal 'ass_exists.last_name', sort_fields[:ass_exist][:order]
  end

  def test_default_association_sort_field
    sort_on :ass_exist
    assert_equal 'ass_exists.name', sort_fields[:ass_exist][:order]
  end

  def test_argument_errors
    assert_raise ArgumentError do
      sort_on :ass_imaginary
    end

    assert_raise ArgumentError do
      sort_on false
    end

    assert_raise ArgumentError do
      sort_on :ass_exist => :nonexistent
    end
  end

  def test_multiple_declarations
    sort_on :foo
    sort_on :bar
    assert_equal 2, sort_fields.length
    assert_equal( { :order => 'foo' }, sort_fields[:foo])
    assert_equal( { :order => 'bar' }, sort_fields[:bar])
  end

  def test_sort_by
    sort_on :foo
    assert_equal( { :order => 'foo' }, sort_by( :field => 'foo', :down => '' ))
    assert_equal( { :order => 'foo DESC'}, sort_by( :field => 'foo', :down => 'true' ))
    assert_raise ArgumentError do
      sort_by( :field => 'bar', :down => '' )
    end
    assert_nil sort_by nil
    assert_nil sort_by( :field => 'foo' )
    assert_nil sort_by( :down => '' )
    assert_nil sort_by( :down => 'true' )

    sort_on :ass_exist
    assert_equal( { :joins => :ass_exist, :order => 'ass_exists.name' }, sort_by( :field => 'ass_exist', :down => '' ))
    assert_equal( { :joins => :ass_exist, :order => 'ass_exists.name DESC' }, sort_by( :field => 'ass_exist', :down => 'true' ))
  end

  def teardown
    GoodSort::Sorter.send :class_variable_set, :@@sort_fields, {}
  end
end
