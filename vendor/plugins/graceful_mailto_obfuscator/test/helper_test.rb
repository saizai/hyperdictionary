require File.dirname(__FILE__) + '/test_helper'

context "The mail_to rails helper" do
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  
  specify "should be overridden to return an obfuscated email" do
    mail_to("me@mail.com", "mail me").should.match "zr+znvy+pbz"
  end
  
  specify "should be able to decode an obfuscated email" do
    Loopy::EmailObfuscator.decode_email("zr+znvy+pbz").should.equal "me@mail.com"
  end
  
  specify "should add an obfuscated class to the anchor when using the email_to helper" do
    mail_to("me@mail.com").should.match "class=\"obfuscated\""
  end
end