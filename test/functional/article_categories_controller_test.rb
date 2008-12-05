require 'test_helper'

class ArticleCategoriesControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:article_categories)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_article_category
    assert_difference('ArticleCategory.count') do
      post :create, :article_category => { }
    end

    assert_redirected_to article_category_path(assigns(:article_category))
  end

  def test_should_show_article_category
    get :show, :id => article_categories(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => article_categories(:one).id
    assert_response :success
  end

  def test_should_update_article_category
    put :update, :id => article_categories(:one).id, :article_category => { }
    assert_redirected_to article_category_path(assigns(:article_category))
  end

  def test_should_destroy_article_category
    assert_difference('ArticleCategory.count', -1) do
      delete :destroy, :id => article_categories(:one).id
    end

    assert_redirected_to article_categories_path
  end
end
