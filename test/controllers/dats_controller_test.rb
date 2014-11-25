require 'test_helper'

class DatsControllerTest < ActionController::TestCase
  setup do
    @dat = dats(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dats)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dat" do
    assert_difference('Dat.count') do
      post :create, dat: {  }
    end

    assert_redirected_to dat_path(assigns(:dat))
  end

  test "should show dat" do
    get :show, id: @dat
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dat
    assert_response :success
  end

  test "should update dat" do
    patch :update, id: @dat, dat: {  }
    assert_redirected_to dat_path(assigns(:dat))
  end

  test "should destroy dat" do
    assert_difference('Dat.count', -1) do
      delete :destroy, id: @dat
    end

    assert_redirected_to dats_path
  end
end
