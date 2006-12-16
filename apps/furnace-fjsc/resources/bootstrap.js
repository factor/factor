function Word(name, source, func) {
  this.name = name;
  this.source = source;
  this.func = func;
}

Word.prototype.execute = function(world, next) {
  this.func(world,next);
}

function Continuation() {
  this.data_stack = [ ];
  this.retain_stack = [ ];
}

Continuation.prototype.clone = function() {
  var c = new Continuation();
  c.data_stack = this.data_stack.slice(0);
  c.retain_stack = this.retain_stack.slice(0);
  return c;
}

function Factor() {
  this.words = { };
  this.cont = new Continuation();
  this.form = false ;
  this.next = false;
}

var factor = new Factor();

factor.words["dup"] = new Word("dup", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  stack[stack.length] = stack[stack.length-1];
  next(world);
});

factor.words["drop"] = new Word("drop", "primitive", function(world, next) {
  world.cont.data_stack.pop();
  next(world);
});

factor.words["nip"] = new Word("nip", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  stack[stack.length-2] = stack[stack.length-1];
  stack.pop();
  next(world);
});

factor.words["over"] = new Word("over", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  stack[stack.length] = stack[stack.length-2];
  next(world);
});

factor.words["swap"] = new Word("swap", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  var temp = stack[stack.length-2];
  stack[stack.length-2] = stack[stack.length-1];
  stack[stack.length-1] = temp;
  next(world);
});

factor.words[">r"] = new Word(">r", "primitive", function(world, next) {
  var data_stack = world.cont.data_stack;
  var retain_stack = world.cont.retain_stack;
  retain_stack.push(data_stack.pop());
  next(world);
});

factor.words["r>"] = new Word("r>", "primitive", function(world, next) {
  var data_stack = world.cont.data_stack;
  var retain_stack = world.cont.retain_stack;
  data_stack.push(retain_stack.pop());
  next(world);
});

factor.words["*"] = new Word("*", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  stack.push(stack.pop() * stack.pop());
  next(world);
});

factor.words["+"] = new Word("+", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  stack.push(stack.pop() + stack.pop());
  next(world);
});

factor.words["-"] = new Word("-", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 - v1);
  next(world);
});

factor.words["/"] = new Word("/", "primitive", function(world, next) {
  var stack = world.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 / v1);
  next(world);
});

factor.words["."] = new Word(".", "primitive", function(world, next) {
  alert(world.cont.data_stack.pop());
  next(world);
});

factor.words["call"] = new Word("call", "primitive", function(world, next) {
  var quot = world.cont.data_stack.pop();
  quot.execute(world, next);
});

factor.words["execute"] = new Word("execute", "primitive", function(world, next) {
  var quot = world.cont.data_stack.pop();
  quot.execute(world, next);
});

factor.words["clear"] = new Word("clear", "primitive", function(world, next) {
  world.cont.data_stack = [];
  world.cont.retain_stack = [];
  next(world);
});

factor.words["square"] = new Word("square", "primitive", function(world, next) {  
  var stack = world.cont.data_stack;
  stack[stack.length-1] = stack[stack.length-1] * stack[stack.length-1];
  next(world);
});

factor.words["if"] = new Word("if", "primitive", function(world, next) {  
  var stack = world.cont.data_stack;
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
  world.cont.data_stack.push(false);
  next(world);
});

factor.words["t"] = new Word("t", "primitive", function(world, next) {  
  world.cont.data_stack.push(true);
  next(world);
});

factor.words["="] = new Word("=", "primitive", function(world, next) {   
  var stack = world.cont.data_stack;
  stack.push(stack.pop()==stack.pop());
  next(world);
});

factor.words["window"] = new Word("window", "primitive", function(world, next) {  
  world.cont.data_stack.push(window);
  next(world);
});

factor.words["bootstrap"] = new Word("bootstrap", "primitive", function(world, next) {  
  world.cont.data_stack.push("/responder/fjsc-resources/bootstrap.factor");
  world.words["run-file"].execute(world, next);
});

factor.words["run-file"] = new Word("run-file", "primitive", function(world, next) {  
  var stack = world.cont.data_stack;
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
  var data_stack = world.cont.data_stack;
  var quot = data_stack.pop();
  var new_cont = world.cont.clone();  
  var old_next = world.next;
  var cont = {
    world: world,
    next: function(world) {
      world.next = old_next;
      next(world);
    },
    cont: world.cont
  };
  new_cont.data_stack.push(cont);
  world.cont = new_cont;;
  quot.execute(world, next);  
});

factor.words["continue"] = new Word("continue", "primitive", function(world, next) {  
  var data_stack = world.cont.data_stack;
  var cont = data_stack.pop(); 
  world.cont = cont.cont.clone();
  (cont.next)(world);
});

factor.words["alien-invoke"] = new Word("alien-invoke", "primitive", function(world, next) {  
  var stack = world.cont.data_stack;
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

Factor.prototype.push_data = function(v, world, next) {
  world.cont.data_stack.push(v);
  next(world);
}

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
   for(var i = 0; i < this.cont.data_stack.length; ++i) {
      html.push("<tr><td>")
      html.push(this.cont.data_stack[i])
      html.push("</td></tr>")
   }
   html.push("</table>")
   document.getElementById('stack').innerHTML=html.join("");
}