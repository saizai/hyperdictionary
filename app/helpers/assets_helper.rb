module AssetsHelper
  def icon asset
    if asset.image?
      content_tag(:span, image_tag(asset.public_filename(:icon)) + 
                    content_tag(:span, image_tag(asset.public_filename(:thumb))),
                  :class => 'tooltip icon')
    else
      # use something based on mime type
      content_tag(:span, '&nbsp;', :class => 'icon')
    end
  end
end
