require 'test_helper'
require 'good_sort/sorter'
require 'active_support'

module MockupStuff
  def setup_mock(m,n); @_m = m; @_n = n; end
  def columns_hash; { 'foo' => true, 'bar' => true }; end
  def quoted_table_name; self.to_s.tableize; end
  def class_name; self.to_s; end
  def reflect_on_association(a)
    ass = @_m
    ass.stubs(:belongs_to?).returns(a.to_sym == :ass_exist)

    ass.stubs(:quoted_table_name).returns(a.to_s.tableize)

    ass_klass = @_n
    ass_klass.stubs(:column_names).returns( %w{name last_name} )

    ass.stubs(:klass).returns(ass_klass)

    ass
  end
end

class Todel
  extend GoodSort::Sorter
  extend MockupStuff
end

class Yodel
  extend GoodSort::Sorter
  extend MockupStuff
end

class GoodSortSorterTest < Test::Unit::TestCase

  def setup
    Todel.instance_variable_set :@sort_fields, {}
    Todel.setup_mock(mock,mock)
  end

  def test_multiple_models
    Yodel.instance_variable_set :@sort_fields, {}
    Yodel.setup_mock(mock,mock)

    Yodel.send :sort_on, :ass_exist => :last_name
    Todel.send :sort_on, :foo, :ass_exist

    assert_equal( { :joins => :ass_exist, :order => "ass_exists.last_name" }, Yodel.sort_fields[:ass_exist])

    assert_equal( { :order => "todels.foo" }, Todel.sort_fields[:foo])
    assert_equal( { :joins => :ass_exist, :order => "ass_exists.name" }, Todel.sort_fields[:ass_exist])

    assert_nil Yodel.sort_fields[:foo]
  end

  def test_sort_on_our_attributes
    Todel.send :sort_on, :foo, :bar
    assert_equal 2, Todel.sort_fields.length
    assert_equal( { :order => "todels.foo" }, Todel.sort_fields[:foo])
    assert_equal( { :order => "todels.bar" }, Todel.sort_fields[:bar])
  end

  def test_association_sort_fields
    Todel.send :sort_on, :ass_exist => :last_name
    assert_equal "ass_exists.last_name", Todel.sort_fields[:ass_exist][:order]
  end

  def test_default_association_sort_field
    Todel.send :sort_on, :ass_exist
    assert_equal "ass_exists.name", Todel.sort_fields[:ass_exist][:order]
  end

  def test_argument_errors
    assert_raise ArgumentError do
      Todel.send :sort_on, :ass_imaginary
    end

    assert_raise ArgumentError do
      Todel.send :sort_on, false
    end

    assert_raise ArgumentError do
      Todel.send :sort_on, :ass_exist => :nonexistent
    end
  end

  def test_multiple_declarations
    Todel.send :sort_on, :foo
    Todel.send :sort_on, :bar
    assert_equal 2, Todel.sort_fields.length
    assert_equal( { :order => "todels.foo" }, Todel.sort_fields[:foo])
    assert_equal( { :order => "todels.bar" }, Todel.sort_fields[:bar])
  end

  def test_sort_by
    Todel.send :sort_on, :foo
    assert_equal( { :order => "todels.foo" }, Todel.sort_by( :field => 'foo', :down => '' ))
    assert_equal( { :order => "todels.foo DESC"}, Todel.sort_by( :field => 'foo', :down => 'true' ))
    assert_raise ArgumentError do
      Todel.sort_by( :field => 'bar', :down => '' )
    end
    assert_nil Todel.sort_by nil
    assert_nil Todel.sort_by( :field => "todels.foo" )
    assert_nil Todel.sort_by( :down => '' )
    assert_nil Todel.sort_by( :down => 'true' )

    Todel.send :sort_on, :ass_exist
    assert_equal( { :joins => :ass_exist, :order => "ass_exists.name" }, Todel.sort_by( :field => 'ass_exist', :down => '' ))
    assert_equal( { :joins => :ass_exist, :order => "ass_exists.name DESC" }, Todel.sort_by( :field => 'ass_exist', :down => 'true' ))
  end
end
