module AssetsHelper
  def icon asset
    if asset.image?
      content_tag(:span, image_tag(asset.public_filename(:icon)) + 
                    content_tag(:span, image_tag(asset.public_filename(:thumb))),
                  :class => 'tooltip')
    else
      # use something based on mime type
    end
  end
end
