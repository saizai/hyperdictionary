if (!UserVoice) {
  var UserVoice = {}
}

if (!UserVoice.Util) {
UserVoice.Util = {
	sslAssetHost: "https://uservoice.com",
	assetHost: "http://cdn.uservoice.com",
  getAssetHost: function() {
    return ("https:" == document.location.protocol) ? this.sslAssetHost : this.assetHost
  },
  requireCss: function(path) {
	  document.write('<style type="text/css" media="screen">@import url(\'' + this.getAssetHost() + '/stylesheets/' + path + '\');</style>')
  },
  requireJs: function(path) {
		document.write('<script type="text/javascript" src=\'' + this.getAssetHost() + '/javascripts/' + path  + '\'></script>')
  },
  render: function(template, params) {
    return template.replace(/\#{([^{}]*)}/g,
      function (a, b) {
          var r = params[b]
          return typeof r === 'string' || typeof r === 'number' ? r : a
      }
    )
  },
  toQueryString: function(params) {
	  var pairs = []
	  for (key in params) { 
		  if (params[key] != null && params[key] != '') {
  		  pairs.push([key, params[key]].join('='))
      }
    }
    return pairs.join('&')
  }
}
}

UserVoice.Util.requireJs('lib/dialog.js')

UserVoice.Popin = {
  content_template: '<iframe src="#{url}/widgets/#{dialog}.html?#{query}" frameborder="0" scrolling="no" allowtransparency="true" width="#{width}" height="#{height}" style="height: #{height}; width: #{width};"></iframe>',
	setup: function(options) {
    this.setupOptions(options || {})
	},
	show: function() {
	  UserVoice.Dialog.show(UserVoice.Util.render(this.content_template, this.options))
	},
  setupOptions: function(options) {
	  this.options = {
		  dialog: 'popin',
		  width: '350px',
		  height: '430px',
		  lang: 'en',
		  params: {}
	  }
    for (attr in options) { this.options[attr] = options[attr] }
	  this.options.url = this.url()	 

    this.options.params.lang = this.options.lang
    this.options.params.referer = this.getReferer()
	  this.options.query = UserVoice.Util.toQueryString(this.options.params)
  },
  getReferer: function() {
		var referer = window.location.href
	  if (referer.indexOf('?') != -1) { referer = referer.substring(0, referer.indexOf('?')) } // strip params
	  return referer
	},
  url: function() {
	  if ("https:" == document.location.protocol && this.options.key != null) {
		  // HTTPS requests should always go to xxx.uservoice.com
		  var url = 'https://' + this.options.key + '.uservoice.com/pages/' + this.options.forum
    } else {
	  	var url =  'http://' + this.options.host + '/pages/' + this.options.forum
    }
    return url
  }
}

UserVoice.Tab = {
	id: "uservoice-feedback-tab",
	css_template: "a##{id} { #{alignment}: 0; background-repeat: no-repeat; background-color: #{background_color}; background-image: url(#{text_url}); border: outset 1px #{background_color}; border-#{alignment}: none; -moz-border-radius: 1em; -moz-border-radius-top#{alignment}: 0; -moz-border-radius-bottom#{alignment}: 0; -webkit-border-radius: 1em; -webkit-border-top-#{alignment}-radius: 0; -webkit-border-bottom-#{alignment}-radius: 0;}" +
     "a##{id}:hover { background-color: #{hover_color}; border: outset 1px #{hover_color}; border-#{alignment}: none; }" +
     "* html a##{id} { filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src='#{text_url}'); }",

  show: function(options) {
    this.setupOptions(options || {})
    UserVoice.Popin.setup(options)
		UserVoice.Util.requireCss('widgets/tab.css')
    document.write('<a id="' + this.id + '" onclick="UserVoice.Popin.show(); return false;" href="' + UserVoice.Popin.url() + '"></a>')		
	  document.write('<style type="text/css">' + UserVoice.Util.render(this.css_template, this.options) + '</style>')
  },
  setupOptions: function(options) {
	  this.options = {
		  alignment: 'left',
		  background_color:'#f00', 
		  text_color: 'white',
		  hover_color:'#06C',
		  lang: 'en'
	  }
    for (attr in options) { this.options[attr] = options[attr] }

	  this.options.text_url = UserVoice.Util.getAssetHost() + '/images/widgets/' + this.options.lang + '/feedback_tab_' + this.options.text_color + '.png'
	  this.options.id = this.id	
  }

}

