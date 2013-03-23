require 'test_helper'

class GroupTest < ActiveSupport::TestCase
  test "reindex none" do
    assert_equal 0, Group.where(:user_id => 101).count

    Group.reindex(101)

    assert_equal 0, Group.where(:user_id => 101).count
  end

  test "reindex one group" do
    g0 = Group.create(:user_id => 101, :name => "0", :index_num => 0)
    assert_equal(1, Group.where(:user_id => 101).count)
    Group.reindex(101)
    assert_equal(1, Group.where(:user_id => 101).count)
    assert_equal(g0, Group.where(:user_id => 101)[0])
  end

  test "reindex two groups that are in order" do
    g0 = Group.create(:user_id => 101, :name => "0", :index_num => 0)
    g1 = Group.create(:user_id => 101, :name => "1", :index_num => 1)
    assert_equal(2, Group.where(:user_id => 101).count)
    Group.reindex(101)
    groups = Group.where(:user_id => 101).order("index_num asc")
    assert_equal(2, groups.count)
    assert_equal(g0, groups[0])
    assert_equal(0, groups[0].index_num)
    assert_equal(g1, groups[1])
    assert_equal(1, groups[1].index_num)
  end

  test "reindex two groups with a gap (ie [0,2])" do
    g0 = Group.create(:user_id => 101, :name => "0", :index_num => 0)
    g1 = Group.create(:user_id => 101, :name => "1", :index_num => 2)
    assert_equal(2, Group.where(:user_id => 101).count)
    Group.reindex(101)
    groups = Group.where(:user_id => 101).order("index_num asc")
    assert_equal(2, groups.count)
    assert_equal(g0, groups[0])
    assert_equal(0, groups[0].index_num)
    assert_equal(g1, groups[1])
    assert_equal(1, groups[1].index_num)
  end

  test "reindex a bunch of gaps" do
    Group.create(:user_id => 101, :index_num => 2)
    Group.create(:user_id => 101, :index_num => 3)
    Group.create(:user_id => 101, :index_num => 7)
    Group.create(:user_id => 101, :index_num => 9)
    Group.create(:user_id => 101, :index_num => 12)
    Group.create(:user_id => 101, :index_num => 13)
    Group.create(:user_id => 101, :index_num => 14)
    Group.create(:user_id => 101, :index_num => 22)
    Group.reindex(101)
    groups = Group.where(:user_id => 101).order("index_num asc")
    groups.each_with_index do |group, index|
      assert_equal(index, group.index_num)
    end
  end
end
