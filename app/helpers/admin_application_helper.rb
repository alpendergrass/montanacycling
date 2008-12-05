module AdminApplicationHelper
  
  def display_categories(categories, parent_id)
    ret = "<ul>" 
      for category in categories
        if category.parent_id == nil
      	  category.parent_id = 0
        elsif category.parent_id == parent_id
          ret << display_category(category)
        end
      end
    ret << "</ul>" 
  end

  def display_category(category)
    ret = "<li>"
    ret << link_to(h(category.name), :action => "edit", :id => category)
    ret << display_categories(category.children, category.id) if category.children.any?
    ret << "</li>" 
  end
end

  def tree_select(categories, model, name, selected=0, level=0, init=true)
    html = ""
    # The "Root" option is added
    # so the user can choose a parent_id of 0
    if init
        # Add "Root" to the options
        html << "<select name=\"#{model}[#{name}]\" id=\"#{model}_#{name}\">\n"
        html << "\t<option value=\"0\""
        html << " selected=\"selected\"" if selected.parent_id == 0
        html << ">Root</option>\n"
    end

    if categories.length > 0
      level += 1 # keep position
      categories.collect do |cat|
        html << "\t<option value=\"#{cat.id}\" style=\"padding-left:#{level * 10}px\""
        html << ' selected="selected"' if cat.id == selected.parent_id
        html << ">#{cat.name}</option>\n"
        html << tree_select(cat.children, model, name, selected, level, false)
      end
    end
    html << "</select>\n" if init
    return html
  end
