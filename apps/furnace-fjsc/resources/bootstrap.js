function Word(name, source, func) {
  this.name = name;
  this.source = source;
  this.func = func;
}

Word.prototype.execute = function(world, next) {
  this.func(world,next);
}

function Stack() {
  this.stack = [];
}

Stack.prototype.push = function(v,world,next) {
  this.stack.push(v);
  next(world);
}

Stack.prototype.pop = function(world,next) {
  this.stack.pop();
  next(world);
}

Stack.prototype.clone = function() {
  var stack = new Stack();
  stack.stack = this.stack.slice(0);
  return stack;
}

function Factor() {
  this.words = { };
  this.data_stack = new Stack();
  this.form = false ;
  this.next = false;
}

var factor = new Factor();

factor.words["dup"] = new Word("dup", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  stack[stack.length] = stack[stack.length-1];
  next(world);
});

factor.words["drop"] = new Word("drop", "primitive", function(world, next) {
  world.data_stack.stack.pop();
  next(world);
});

factor.words["nip"] = new Word("nip", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  stack[stack.length-2] = stack[stack.length-1];
  stack.pop();
  next(world);
});

factor.words["over"] = new Word("over", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  stack[stack.length] = stack[stack.length-2];
  next(world);
});

factor.words["swap"] = new Word("swap", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  var temp = stack[stack.length-2];
  stack[stack.length-2] = stack[stack.length-1];
  stack[stack.length-1] = temp;
  next(world);
});

factor.words["*"] = new Word("*", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  stack.push(stack.pop() * stack.pop());
  next(world);
});

factor.words["+"] = new Word("+", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  stack.push(stack.pop() + stack.pop());
  next(world);
});

factor.words["-"] = new Word("-", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 - v1);
  next(world);
});

factor.words["/"] = new Word("/", "primitive", function(world, next) {
  var stack = world.data_stack.stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 / v1);
  next(world);
});

factor.words["."] = new Word(".", "primitive", function(world, next) {
  alert(world.data_stack.stack.pop());
  next(world);
});

factor.words["call"] = new Word("call", "primitive", function(world, next) {
  var quot = world.data_stack.stack.pop();
  quot.execute(world, next);
});

factor.words["execute"] = new Word("execute", "primitive", function(world, next) {
  var quot = world.data_stack.stack.pop();
  quot.execute(world, next);
});

factor.words["clear"] = new Word("clear", "primitive", function(world, next) {
  world.data_stack.stack = [];
  next(world);
});

factor.words["square"] = new Word("square", "primitive", function(world, next) {  
  var stack = world.data_stack.stack;
  stack[stack.length-1] = stack[stack.length-1] * stack[stack.length-1];
  next(world);
});

factor.words["if"] = new Word("if", "primitive", function(world, next) {  
  var stack = world.data_stack.stack;
  var else_quot = stack.pop();
  var then_quot = stack.pop();
  var condition = stack.pop();
  if(condition) {
    then_quot.execute(world, next);
  } else {
    else_quot.execute(world, next);
  }
});

factor.words["f"] = new Word("f", "primitive", function(world, next) {  
  world.data_stack.stack.push(false);
  next(world);
});

factor.words["t"] = new Word("t", "primitive", function(world, next) {  
  world.data_stack.stack.push(true);
  next(world);
});

factor.words["="] = new Word("=", "primitive", function(world, next) {   
  var stack = world.data_stack.stack;
  stack.push(stack.pop()==stack.pop());
  next(world);
});

factor.words["window"] = new Word("window", "primitive", function(world, next) {  
  world.data_stack.stack.push(window);
  next(world);
});

factor.words["bootstrap"] = new Word("bootstrap", "primitive", function(world, next) {  
  world.data_stack.stack.push("/responder/fjsc-resources/bootstrap.factor");
  world.words["run-file"].execute(world, next);
});

factor.words["run-file"] = new Word("run-file", "primitive", function(world, next) {  
  var stack = world.data_stack.stack;
  var url = stack.pop();
  var callback = {
    success: function(o) {
      var result = o.responseText;
      world.server_eval(result, world, next);
    },
    failure: function(o) {
      alert('run-file failed');
      next(world);
    }
  };
  YAHOO.util.Connect.asyncRequest('GET', url, callback, null);
});

factor.words["callcc0"] = new Word("callcc0", "primitive", function(world, next) {  
  var stack = world.data_stack;
  var quot = stack.stack.pop();
  var new_stack = stack.clone();  
  var old_next = world.next;
  var cont = {
    world: world,
    next: function(world) {
      world.next = old_next;
      next(world);
    },
    stack: stack
  };
  new_stack.stack.push(cont);
  world.data_stack = new_stack;
  quot.execute(world, next);  
});

factor.words["continue"] = new Word("continue", "primitive", function(world, next) {  
  var stack = world.data_stack;
  var cont = stack.stack.pop(); 
  world.data_stack = cont.stack.clone();
  (cont.next)(world);
});

factor.words["alien-invoke"] = new Word("alien-invoke", "primitive", function(world, next) {  
  var stack = world.data_stack.stack;
  var arg_types = stack.pop();
  var method_name = stack.pop();
  var library_name = stack.pop();
  var return_values = stack.pop();
  var obj = stack.pop();
  var args = [ ];
  for(var i = 0; i < arg_types.length; ++i) {
    args[i] = stack.pop();
  }
  var v = obj[method_name].apply(obj, args);
  if(return_values.length > 0)
    stack.push(v);
  next(world);
});

Factor.prototype.define_word = function(name, source, func, world, next) {
  factor.words[name] = new Word(name, source, function(world, next) {
    var old = world.next;
    world.next = function(world) {
      world.next = old;
      next(world);
    }
    func(world);
  });
  next(world);
}

Factor.prototype.make_quotation = function(source, func) {
  return new Word("quotation", source, function(world, next) {
    var old = world.next;
    world.next = function(world) {
      world.next = old;
      next(world);
    }
    func(world);
  });
}

Factor.prototype.call_alien = function(has_return,method_name, object, args, world, next) {
  var v = object[method_name].apply(object, args);
  if(has_return)
    world.data_stack.stack.push(v);
  next(world);
}


Factor.prototype.server_eval = function(text, world, next) {
   var self = this;
   var callback = {
      success: function(o) {
	 var v = o.responseText;
	 document.getElementById('compiled').innerHTML="<pre>" + v + "</pre>";
	 document.getElementById('code').value="";
	 var func = eval(v);
         factor.next = function() { self.display_datastack(); } 
	 func(factor);
         if(world && next) 
           next(world);
      }
   };
   this.form.code.value=text;
   YAHOO.util.Connect.setForm(this.form);
   YAHOO.util.Connect.asyncRequest('POST', "/responder/fjsc/compile", callback);
}

Factor.prototype.fjsc_eval = function(form) {
   this.form = form;
   this.server_eval(form.code.value);
}

Factor.prototype.display_datastack = function() {
   var html=[];
   html.push("<table border='1'>")
   for(var i = 0; i < this.data_stack.stack.length; ++i) {
      html.push("<tr><td>")
      html.push(this.data_stack.stack[i])
      html.push("</td></tr>")
   }
   html.push("</table>")
   document.getElementById('stack').innerHTML=html.join("");
}

