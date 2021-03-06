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

  def main_library_name
    "Main Library"
  end

  def main_library_id
    "john:MainLibrary"
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

end
