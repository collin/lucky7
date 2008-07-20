Lucky7.templates = {};

Lucky7.Template = function(name, source) {
  if(source) {
    Lucky7.templates[name] = new Lucky7.TemplateObject(source);
  }
  return Lucky7.templates[name]
};

Lucky7.TemplateObject = function(source) {
  this.source = source;
};

Lucky7.TemplateObject.prototype = {
  pattern: /((#|=|\?)\{(.*?)\})/g

  ,'#': function(mtch, capture, start, end, all) {
    this.cache.push({prop: capture});
  }

  ,'=': function(mtch, capture, start, end, all) {
    this.cache.push(function(context) {
        if(!context[capture]) return;
        if(context[capture].constructor === Array) {
          var i, length = context[capture].length, map = [];
          for(var i=0; i < length; i++) {
            map.push(Lucky7.Template(capture).render(context[capture][i]));
          }
          return map.join('');
        }
        else {
          return Lucky7.Template(capture).render(context[capture]);
        }
    });
  }

  ,'?':  function(mtch, capture, start, end, all) {
    this.cache.push(function(context) {
console.log(capture, context)
      if(!context[capture]) return;
console.log(context[capture])
      return Lucky7.Template(context[capture]).render(context);
    });
  }

  ,generateCacheArray: function(string) {
    var start = 0;
    this.cache = [];
    var that = this;

    string.replace(this.pattern, 
      function generateCacheArray_string_replace(mtch, _, _, capture, end) {
        that.cache.push(string.substr(start, end - start));
        that[mtch.charAt(0)](mtch, capture, start, end, string);
        start = end + mtch.length;
        return mtch;
      }
    );
    this.cache.push(string.substr(start));
  }

  ,compile: function() {
    this.generateCacheArray(this.source);
    this.compiledFunction = function (context) {
      var eachBit = [],
          length = this.cache.length,
          i, bit;

      for(i=0;i < length; i++) {
        if(this.cache[i].prop)
          bit = context[this.cache[i].prop];
        else
          bit = this.cache[i];

        if(bit instanceof Function) bit = bit(context);

        eachBit[i] = bit
      }
      return eachBit.join('');
    };
  }

  ,"notCompiled?": function() {
    return !this.hasOwnProperty('compiledFunction');
  }

  ,render: function(context) {
    if(this["notCompiled?"]) this.compile();
    return this.compiledFunction(context);
  }
};
