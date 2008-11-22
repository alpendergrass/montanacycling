require File.dirname(__FILE__) + '/../../bdrb_test_helper'
require File.dirname(__FILE__) + '/../../test_helper'
require "workers/mailer_worker"
require 'admin/emails_controller'

class Admin::EmailsController; def rescue_action(e) raise e end; end

class Admin::EmailsControllerTest < ActiveSupport::TestCase
  def setup
    @controller = Admin::EmailsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @request.session[:user] = users(:candi)
  end

  def test_new
    get(:new)
    assert_response(:success)
    assert_not_nil(assigns['email'], 'Should assign email')
    assert_not_nil(assigns['members_count'], 'Should assign members_count')
  end
  
  def test_confirm
    post(:confirm, :email => { :from => "scott@butlerpress.com", :subject => "Masters Racing", :body => "My opinion" })
    assert_response(:success)
    assert_not_nil(assigns['email'], 'Should assign email')
    assert_not_nil(assigns['members_count'], 'Should assign members_count')
    assert_equal(["scott@butlerpress.com"], assigns['email'].from, "from")
    assert_equal("Masters Racing", assigns['email'].subject, "subject")
    assert_equal("My opinion", assigns['email'].body, "body")
  end
  
  def test_create
    post(:create, :email => { :from => "scott@butlerpress.com", :subject => "Masters Racing", :body => "My opinion" })
    assert_redirected_to(:action => "new")
    assert(!Admin::MemberMailer.deliveries.empty?, "Should deliver")
    assert_not_nil(flash[:info])
  end
  
  def test_no_from_should_be_invalid
    post(:confirm, :email => { :subject => "Masters Racing", :body => "My opinion" })
    assert_response(:success)
    assert_not_nil(flash[:warn])
  end
  
  def test_no_subject_should_be_invalid
    post(:confirm, :email => { :from => "scott@butlerpress.com", :body => "My opinion" })
    assert_response(:success)
    assert_not_nil(flash[:warn])
  end
  
  def test_no_body_should_be_invalid
    post(:confirm, :email => { :subject => "Masters Racing", :from => "scott@butlerpress.com" })
    assert_response(:success)
    assert_not_nil(flash[:warn])
  end
end
