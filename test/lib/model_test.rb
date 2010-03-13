require File.dirname(__FILE__) + "/../test_helper"

class ModelTest < ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  def setup
    @audi     = Car.find_by_name("Audi")
    @infinity = Car.find_by_name("Infinity")

    @denis = User.find_by_name("Denis Odorcic")
  end

  def test_find_statement
    assert_equal Car.find_statement(:stars, 7).size, 0
    assert_equal Car.find_statement(:stars, 8).size, 1
    assert_equal Car.find_statement(:stars, 8, :speed).size, 1
    assert_equal Car.find_statement(:stars, 5, :reliability).size, 2
  end

  def test_rate_higher_than_max_stars
    assert_equal Car.max_stars, 10
    assert !@audi.rate(15, User.first)
  end

  def test_already_rated_error
    Car.axr_config[:allow_update] = false
    assert @audi.rated_by?(@denis)
    assert_raise AjaxfulRating::Errors::AlreadyRatedError do
      @audi.rate(4, @denis)
    end
  end

  def test_already_rated_and_allowed_to_update
    assert @audi.rated_by?(@denis)
    stars = @audi.rate_by(@denis).stars

    assert_no_difference 'Rate.count' do
      @audi.rate(1, @denis)
    end
    assert_equal @audi.rate_by(@denis).stars, 1
    assert_not_equal @audi.rate_by(@denis).stars, stars
  end

  def test_new_rating
    assert_difference 'Rate.count', 1 do
      @audi.rate(5, @denis, :price)
    end
  end

  def test_raters
    assert_equal @audi.raters.size, 2
    assert_difference 'Rate.count', 1 do
      @audi.rate(3, User.create(:name => "Bob"))
    end
    assert_equal @audi.raters.size, 3
  end

end
