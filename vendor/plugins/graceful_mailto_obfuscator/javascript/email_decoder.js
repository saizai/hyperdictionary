EmailDecoder = Behavior.create({
  initialize: function() {
    var anchor = this.element;
    var href = anchor.getAttribute('href');
    var address = href.replace(/.*contactto\/new\/([a-z0-9._%-]+)\+([a-z0-9._%-]+)\+([a-z.]+)/i, '$1' + '@' + '$2' + '.' + '$3'); 
    
    if (href != address) {
      anchor.setAttribute('href', 'mailto:' + this.decode(address));
    }
  }, 
  
  decode: function(encoded) {
    return encoded.replace(/[a-zA-Z]/g, function(c){
        return String.fromCharCode((c <= "Z" ? 90 : 122) >= (c = c.charCodeAt(0) + 13) ? c : c - 26);
    });
  }
});