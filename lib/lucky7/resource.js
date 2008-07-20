Lucky7.Resource = function(name) {
  if(!Lucky7.resources.hasOwnProperty(name)) {
    Lucky7.resources[name] = new Lucky7.ResourceObject();
  }
  return Lucky7.resources[name];
};

Lucky7.ResourceObject = function() {};

Lucky7.ResourceObject.prototype = {
  before: function(method, phunction) {
    var old = this[method],
      that = this;

    this[method] = function() {
      if(method === 'put' || method === 'delete') {
        phunction.apply(arguments[0], arguments);
      }
      else {
        phunction.apply(that, arguments);
      }
      return old.apply(that, arguments);
    };
  }
  
  ,after: function(method, phunction) {
    var old = this[method],
      that = this;

    this[method] = function() {
      var value = old.apply(that, arguments);
      phunction.call(value);
      return value
    };
  }

  ,get: function(id)  {
    return Lucky7.resourceInstances[id];
  }

  ,post: function(data) {
    var id = Lucky7.increment++;
    data.id = id;
    var resource = new Lucky7.ResourceInstance(data, this);
    Lucky7.resourceInstances[id] = resource;
    return resource;
  }

  ,put: function(instance, data) {
    jQuery.extend(instance.data, data);
    return instance;   
  }

  ,delete: function(instance) {
    Lucky7.resourceInstances[instance.data.id] = undefined;
    instance.data.id = undefined;
    return instance;
  }
};

Lucky7.resources = {};

Lucky7.increment = 0;

Lucky7.resourceInstances = {};

Lucky7.ResourceInstance = function(data, resource) {
  this.resource = resource;
  this.data = data;
}

Lucky7.ResourceInstance.prototype = {
  put: function(data) {
    return this.resource.put(this, data);
  }

  ,delete: function() {
    return this.resource.delete(this);
  }
};
