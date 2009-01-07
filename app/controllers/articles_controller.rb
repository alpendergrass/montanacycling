class ArticlesController < ApplicationController
  def index
    @articles = Article.find(:all, :conditions => ["article_category_id = ? and display = true", params[:article_category_id]], :order => "title")
    
    # Determine what category id to use to generate sub catg tabs
    @top_level_article_category_id = ArticleCategory.find(params[:article_category_id]).parent_id
    if @top_level_article_category_id == 0
      @top_level_article_category_id = params[:article_category_id]
    end

    params[:article_category_id] = nil

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @articles }
    end
  end

  def show
    @article = Article.find(params[:id])
    
    # Determine what category id to use to generate sub catg tabs
    @top_level_article_category_id = ArticleCategory.find(@article.article_category_id).parent_id
    if @top_level_article_category_id == 0
      @top_level_article_category_id = @article.article_category_id
    end
  end

end
