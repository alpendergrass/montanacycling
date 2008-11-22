require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PromotersControllerTest < ActionController::TestCase
  def setup
    super
    @request.session[:user] = users(:candi)
  end
  
  def test_index
    path = {:controller => "admin/promoters", :action => 'index'}
    assert_routing("/admin/promoters", path)
    assert_recognizes(path, "/admin/promoters/")

    get(:index)
    assert_equal(3, assigns['promoters'].size, "Should assign all promoters to 'promoters'")
    assert_template("admin/promoters/index")
  end
  
  def test_edit
    path = {:controller => "admin/promoters", :action => 'edit', :id => promoters(:brad_ross).to_param}
    assert_routing("/admin/promoters/#{promoters(:brad_ross).to_param}/edit", path)
    
    get(:edit, :id => promoters(:brad_ross).to_param)
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_nil(assigns['event'], "Should not assign 'event'")
    assert_template("admin/promoters/edit")
  end

  def test_edit_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'edit', :id => promoters(:brad_ross).to_param, :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/#{promoters(:brad_ross).to_param}/edit", 
      :event_id => kings_valley.to_param.to_s)
    
    get(:edit, :id => promoters(:brad_ross).to_param, :event_id => kings_valley.to_param.to_s)
    assert_equal(promoters(:brad_ross), assigns['promoter'], "Should assign 'promoter'")
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/promoters/edit")
  end
  
  def test_new
    path = {:controller => "admin/promoters", :action => 'new'}
    assert_routing("/admin/promoters/new", path)
    
    get(:new)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
    assert_template("admin/promoters/edit")
  end

  def test_new_with_event
    kings_valley = events(:kings_valley)
    path = {:controller => "admin/promoters", :action => 'new', :event_id => kings_valley.to_param.to_s}
    assert_recognizes(path, "/admin/promoters/new", :event_id => kings_valley.to_param.to_s)
    
    get(:new, :event_id => kings_valley.to_param.to_s)
    assert_not_nil(assigns['promoter'], "Should assign 'promoter'")
    assert(assigns['promoter'].new_record?, 'Promoter should be new record')
    assert_equal(kings_valley, assigns['event'], "Should Kings Valley assign 'event'")
    assert_template("admin/promoters/edit")
  end
  
  def test_create
    assert_nil(Promoter.find_by_name("Fred Whatley"), 'Fred Whatley should not be in database')
    post(:create, "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = Promoter.find_by_name("Fred Whatley")
    assert_not_nil(promoter, 'New promoter should be database')
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter name')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => promoter.to_param)
  end
  
  def test_update
    promoter = promoters(:brad_ross)
    
    assert_not_equal('Fred Whatley', promoter.name, 'existing promoter name')
    assert_not_equal('(510) 410-2201', promoter.phone, 'existing promoter name')
    assert_not_equal('fred@whatley.net', promoter.email, 'existing promoter email')

    put(:update, :id => promoter.id, 
      "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    assert_equal('Fred Whatley', promoter.name, 'new promoter name')
    assert_equal('(510) 410-2201', promoter.phone, 'new promoter phone')
    assert_equal('fred@whatley.net', promoter.email, 'new promoter email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => promoter.to_param)
  end

  def test_save_new_single_day_existing_promoter_different_info_overwrite
    candi_murray = promoters(:candi_murray)
    new_email = "scout@scout_promotions.net"
    new_phone = "123123"

    put(:update, :id => candi_murray.id, 
      "promoter" => {"name" => candi_murray.name, "phone" => new_phone, "email" => new_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    candi_murray.reload
    assert_equal(candi_murray.name, candi_murray.name, 'promoter old name')
    assert_equal(new_phone, candi_murray.phone, 'promoter new phone')
    assert_equal(new_email, candi_murray.email, 'promoter new email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => candi_murray.to_param)
  end
  
  def test_save_new_single_day_existing_promoter_no_name
    nate_hobson = promoters(:nate_hobson)
    old_name = nate_hobson.name
    old_email = nate_hobson.email
    old_phone = nate_hobson.phone

    put(:update, :id => nate_hobson.id, 
      "promoter" => {"name" => '', "phone" => old_phone, "email" => old_email}, "commit" => "Save")
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    nate_hobson.reload
    assert_equal('', nate_hobson.name, 'promoter name')
    assert_equal(old_phone, nate_hobson.phone, 'promoter old phone')
    assert_equal(old_email, nate_hobson.email, 'promoter old email')
    
    assert_response(:redirect)
    assert_redirected_to(:action => :edit, :id => nate_hobson.to_param)
  end
  
  def test_update_blank_info
    candi_murray = promoters(:candi_murray)

    put(:update, :id => candi_murray.id, 
      "promoter" => {"name" => '', "phone" => '', "email" => ''}, "commit" => "Save")
    
    assert(!assigns['promoter'].errors.empty?, 'promoter should have errors')
    
    candi_murray.reload
    assert(!candi_murray.name.blank?, 'promoter name')
    assert(!candi_murray.email.blank?, 'promoter email')
    assert(!candi_murray.phone.blank?, 'promoter phone')
    
    assert_response(:success)
    assert_template("admin/promoters/edit")
  end

  def test_save_single_day_existing_promoter_different_info_do_not_overwrite
    candi_murray = promoters(:candi_murray)
    candi_old_email = candi_murray.email
    candi_old_phone = candi_murray.phone

    brad_ross = promoters(:brad_ross)
    brad_old_name = brad_ross.name
    brad_old_email = brad_ross.email
    brad_old_phone = brad_ross.phone

    put(:update,
         'id' => candi_murray.to_param,
         "commit"=>"Save", 
         'promoter' => {"name" => brad_ross.name,  "phone"=> candi_murray.phone, "email"=> candi_murray.email}
    )
    
    assert(!assigns['promoter'].errors.empty?, 'promoter should have errors')
    
    candi_murray.reload
    assert_equal(candi_old_email, candi_murray.email, 'Candi email')
    assert_equal(candi_old_phone, candi_murray.phone, 'Candi phone')
    
    brad_ross.reload
    assert_equal(brad_old_name, brad_ross.name, 'brad_ross name')
    assert_equal(brad_old_email, brad_ross.email, 'brad_ross email')
    assert_equal(brad_old_phone, brad_ross.phone, 'brad_ross phone')
    
    assert_response(:success)
    assert_template("admin/promoters/edit")
  end
 
  def test_remember_event_id_on_update
    promoter = promoters(:brad_ross)

    put(:update, :id => promoter.id, 
      "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
      "commit" => "Save",
      "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter.reload
    
    assert_response(:redirect)
    assert_redirected_to(edit_admin_promoter_path(promoter, :event_id => events(:jack_frost).to_param))
  end
  
  def test_remember_event_id_on_create
    post(:create, "promoter" => {"name" => "Fred Whatley", "phone" => "(510) 410-2201", "email" => "fred@whatley.net"}, 
    "commit" => "Save",
    "event_id" => events(:jack_frost).id)
    
    assert_nil(flash['warn'], "Should not have flash['warn'], but has: #{flash['warn']}")
    
    promoter = Promoter.find_by_name('Fred Whatley')
    assert_response(:redirect)
    assert_redirected_to(edit_admin_promoter_path(promoter, :event_id => events(:jack_frost).to_param))
  end
end
