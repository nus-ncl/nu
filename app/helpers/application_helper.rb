module ApplicationHelper

  def submenu_item(code, label, path)
    link = content_tag(:a, label, href: path)
    content_tag('li', link, class: @submenu == code ? 'active' : nil)
  end

  def dropdown_submenu_item(codes, label, &block)
    items = capture(&block)
    li_content = [
      content_tag(:a, label, href: '#', class: "dropdown-toggle", data: { toggle: 'dropdown' }, role: 'button', 'aria-expanded' => 'false'),
      content_tag(:ul, items, class: 'dropdown-menu', role: 'menu')
    ].join.html_safe

    content_tag(:li, li_content, class: codes.include?(@submenu) ? 'active' : nil)
  end

  # shows the section row with label and optional show / hide button
  def section_row(title, section_id, options = nil)
    options ||= {}

    state      = (options[:state] || :closed).to_sym
    show_label = options[:show_label] || 'Show'
    hide_label = options[:hide_label] || 'Hide'

    content = [
      content_tag(:div, content_tag(:h4, title), class: 'col-sm-11')
    ]

    if state != :always_open
      content << content_tag(:div, content_tag(:button, state == :opened ? hide_label : show_label, :class => 'btn btn-xs btn-default', :type => 'button', :data => { show_label: show_label, hide_label: hide_label, toggle: 'collapse', target: "##{section_id}" }, "aria-expanded" => false, "aria-controls" => section_id), class: 'col-sm-1 text-right')
    end

    content_tag(:div, content.join.html_safe, class: 'row section-row')
  end

  def icon_tag(icon, options = nil)
    options ||= {}

    opts = { class: [ 'icon', 'material-icons', [ options[:class] ] ].flatten.reject(&:blank?).join(' ') }
    if options[:tooltip]
      opts['data-toggle'] = 'tooltip'
      opts['data-html'] = true
      opts['title'] = options[:tooltip].gsub('"', '&#34;')
      opts['data-modal-id'] = options[:modal_id]
    end

    content_tag(:i, icon, opts)
  end

  def section_icon(section)
    case section.to_sym
    when :experiments
      'settings_input_component'
    when :projects
      'description'
    when :libraries
      'library_books'
    when :profile
      'person'
    else
      section.to_s
    end
  end

  def section_root_path(section)
    case section.to_sym
    when :profile
      :my_profile
    else
      section.to_sym
    end
  end

  def show_hide_link(section_selector, expanded)
    label = expanded ? 'expand_less' : 'expand_more'
    link_to label, '#', class: 'icon material-icons', data: { toggle: 'expand', expanded: expanded, target: section_selector }
  end

  def help_icon(brief, options = nil)
    options ||= {}
    more_title = options[:more_title]
    more_text  = options[:more_text]
    modal_id = SecureRandom.uuid

    link = link_to('help', '#', class: 'icon material-icons help',
      data: { toggle: 'tooltip', placement: 'left', html: true, modal_id: modal_id },
      role: 'button',
      title: "<p>#{brief}</p><p><a href='#' class='tooltip-more' data-modal-id='#{modal_id}'>Read more</a>".html_safe.gsub('"', "'") )

    [ link, modal(options[:more_title], options[:more_text], id: modal_id) ].join.html_safe
  end

  def modal(title, text, options = nil)
    options ||= {}

    close_button  = content_tag(:button, content_tag(:span, '&times;'.html_safe, 'aria-hidden' => 'true'), 'class' => 'close', 'type' => 'button', 'data-dismiss' => 'modal', 'aria-label' => 'Close').html_safe
    header        = content_tag(:h4, title, class: 'modal-title').html_safe
    modal_header  = content_tag(:div, [ close_button, header ].join.html_safe, class: 'modal-header').html_safe
    modal_body    = content_tag(:div, text.html_safe, class: 'modal-body').html_safe
    modal_content = content_tag(:div, [ modal_header, modal_body ].join.html_safe, class: 'modal-content').html_safe

    modal_dialog  = content_tag(:div, modal_content, class: 'modal-dialog').html_safe
    content_tag(:div, modal_dialog, class: 'modal fade', id: options[:id]).html_safe
  end

  def front_page?
    params[:controller] == 'user_sessions'
  end

  def public_page?
    %w{ user_sessions applications }.include?(params[:controller])
  end

  def icon_link_to(icon, href, options = nil)
    options ||= {}
    cl = options[:class] || ""
    cl = [ cl, 'icon material-icons' ].reject(&:blank?).join(' ')
    link_to(icon, href, options.merge(class: cl))
  end

  def join_requests_link(notifications)
    unread = notifications.select { |n| n.join_project_request? && !JoinRequestsManager.processed?(n.id) }

    badge = nil
    opts = {}
    if unread.count == 0
      opts['class'] = 'noclick'
      opts['disabled'] = true
      opts['data-toggle'] = 'tooltip'
      opts['title'] = 'There are no pending requests to join your project(s).'
    else
      badge = content_tag(:div, unread.count, class: 'badge')
    end

    icon = icon_tag 'storage'

    link_to [ badge, icon ].reject(&:blank?).join.html_safe, :join_project_requests, opts
  end
end
