module AssetsHelper
  def asset_icon asset
    if asset.image?
      content_tag(:span, image_tag(asset.public_filename(:icon)) + 
                    content_tag(:span, image_tag(asset.public_filename(:thumb))),
                  :class => 'tooltip icon')
    else
      # use something based on mime type
      mime_type_icon = "mime_types/#{asset.content_type}.png"
      if File.exist? File.join(RAILS_ROOT, 'public', 'images', mime_type_icon)
        content_tag(:span, image_tag(mime_type_icon), :class => 'icon')
      else
        content_tag(:span, image_tag("mime_types/unknown.png"), :class => 'icon')
      end
    end
  end
end
