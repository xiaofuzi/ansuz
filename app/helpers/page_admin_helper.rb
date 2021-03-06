module PageAdminHelper

	def link_for_tree(page, options = {})	
  	first = options[:is_first] or false
		last = options[:is_last] or false
		new_at = options[:new_at] or 0
		can_delete = options[:can_delete] or true
		
		post_id = page.parent_id.to_s
    output = []
		output << link_to_remote(page.title, {
          :update => 'main',
          :url => edit_admin_page_path(page)
        },
        :class => "tree_title"
      ) + " "
			
    output << link_to_remote( "dn",  
			{	:update => "item#{post_id}", 
				:url => { 
					:action => 'shift_order',
					:id => page.id, 
					:shift => 1},
			},
				:class => "css_button"
				) unless last
				
    output << link_to_remote( "up",  
			{ :update => "item#{post_id}", 
				:url => {
					:action => 'shift_order',
					:id => page.id, 
					:shift => -1}
			},
				:class => "css_button"
					) unless first
					
		 output << link_to_remote( "X",   
						{	:update => "item#{post_id}", 
							:url => { 
								:action => 'destroy', 
								:id => page.id}, 
								:confirm => 'Are you sure?  This will delete this page permanently and all sub-pages will be orphaned!'
						},
							:class => "css_button"
								) if can_delete

		output << link_to_add_page(page, new_at, post_id)
    output.join
  end

  def link_to_add_page(parent_id, order, post_id)
   link_to_remote( "Add", 
	 	{ :update => 'main', 
			:url => {
				:action => 'new', 
				:parent_id => parent_id, 
				:page_order => order, 
			:tree_post_id => post_id },
		},
			:class => "css_button" )
  end

  def render_tree(child, options = {})
    render :partial => 'tree', :object => child, 
      :locals => {
        :is_first => options[:is_first],
        :is_last => options[:is_last],
        :can_delete => options[:can_delete],
        :initialize => options[:initialize]
      }
  end
  
  def tree_ul(acts_as_tree_set, init=true, &block)
    if acts_as_tree_set.size > 0
      ret = '<ul class="main_tree">'
      acts_as_tree_set.collect do |item|
        next if item.parent_id && init
        ret << '<li class="main_node">'
        ret << render(:partial => 'page_controls', :locals => { :page => item })
        ret << yield(item)
        ret << tree_ul(item.children, false, &block) if item.children.size > 0
        ret << '</li>'
      end
      ret << '</ul>'
    end
  end

  def tree_table(acts_as_tree_set, init=true, level=0, &block)
    if acts_as_tree_set.size > 0
      ret =  '<table class=\'tree subdued\'>'
      ret << '  <thead>'
      ret << '    <tr>'
      ret << '      <th>Title</th>'
      ret << '      <th>Status</th>'
      ret << '      <th class=\'actions\'>Actions</th>'
      ret << '    </tr>'
      ret << '  </thead>'
      ret << '  <tbody>'
      acts_as_tree_set.collect do |item|
        next if item.parent_id && init
        ret << tree_row(item, level, &block)
      end
      ret << '  </tbody>'
      ret << '</table>'
    end
  end

  def tree_row item, level=0, &block
    ret  = "<tr class='level-#{level} #{cycle("odd", "even")}'>"
    ret << '  <td class="item">' + yield(item) + '</td>'
    ret << '  <td>' + item.status_text.to_s + '</td>'
    if current_user.can_post?
      controls = render(:partial => 'page_controls', :locals => { :page => item })
    else
      controls = ""
    end
    ret << '  <td class="page-controls">' + controls + '</td>'
    ret << '</tr>'
    item.children.each do |child|
      ret << tree_row(child, level+1, &block)
    end
    ret
  end
end
