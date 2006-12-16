function Word(name, source, func) {
  this.name = name;
  this.source = source;
  this.func = func;
}

Word.prototype.execute = function(next) {
  this.func(next);
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

factor.words["dup"] = new Word("dup", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length] = stack[stack.length-1];
  next();
});

factor.words["drop"] = new Word("drop", "primitive", function(next) {
  factor.cont.data_stack.pop();
  next();
});

factor.words["nip"] = new Word("nip", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length-2] = stack[stack.length-1];
  stack.pop();
  next();
});

factor.words["over"] = new Word("over", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length] = stack[stack.length-2];
  next();
});

factor.words["swap"] = new Word("swap", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var temp = stack[stack.length-2];
  stack[stack.length-2] = stack[stack.length-1];
  stack[stack.length-1] = temp;
  next();
});

factor.words[">r"] = new Word(">r", "primitive", function(next) {
  var data_stack = factor.cont.data_stack;
  var retain_stack = factor.cont.retain_stack;
  retain_stack.push(data_stack.pop());
  next();
});

factor.words["r>"] = new Word("r>", "primitive", function(next) {
  var data_stack = factor.cont.data_stack;
  var retain_stack = factor.cont.retain_stack;
  data_stack.push(retain_stack.pop());
  next();
});

factor.words["*"] = new Word("*", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack.push(stack.pop() * stack.pop());
  next();
});

factor.words["+"] = new Word("+", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack.push(stack.pop() + stack.pop());
  next();
});

factor.words["-"] = new Word("-", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 - v1);
  next();
});

factor.words["/"] = new Word("/", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 / v1);
  next();
});

factor.words["."] = new Word(".", "primitive", function(next) {
  alert(factor.cont.data_stack.pop());
  next();
});

factor.words["call"] = new Word("call", "primitive", function(next) {
  var quot = factor.cont.data_stack.pop();
  quot.execute(next);
});

factor.words["execute"] = new Word("execute", "primitive", function(next) {
  var quot = factor.cont.data_stack.pop();
  quot.execute(next);
});

factor.words["clear"] = new Word("clear", "primitive", function(next) {
  factor.cont.data_stack = [];
  factor.cont.retain_stack = [];
  next();
});

factor.words["square"] = new Word("square", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  stack[stack.length-1] = stack[stack.length-1] * stack[stack.length-1];
  next();
});

factor.words["if"] = new Word("if", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  var else_quot = stack.pop();
  var then_quot = stack.pop();
  var condition = stack.pop();
  if(condition) {
    then_quot.execute(next);
  } else {
    else_quot.execute(next);
  }
});

factor.words["f"] = new Word("f", "primitive", function(next) {  
  factor.cont.data_stack.push(false);
  next();
});

factor.words["t"] = new Word("t", "primitive", function(next) {  
  factor.cont.data_stack.push(true);
  next();
});

factor.words["="] = new Word("=", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  stack.push(stack.pop()==stack.pop());
  next();
});

factor.words["window"] = new Word("window", "primitive", function(next) {  
  factor.cont.data_stack.push(window);
  next();
});

factor.words["bootstrap"] = new Word("bootstrap", "primitive", function(next) {  
  factor.cont.data_stack.push("/responder/fjsc-resources/bootstrap.factor");
  factor.words["run-file"].execute(next);
});

factor.words["run-file"] = new Word("run-file", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  var url = stack.pop();
  var callback = {
    success: function(o) {
      var result = o.responseText;
      factor.server_eval(result, next);
    },
    failure: function(o) {
      alert('run-file failed');
      next();
    }
  };
  YAHOO.util.Connect.asyncRequest('GET', url, callback, null);
});

factor.words["callcc0"] = new Word("callcc0", "primitive", function(next) {  
  var data_stack = factor.cont.data_stack;
  var quot = data_stack.pop();
  var new_cont = factor.cont.clone();  
  var old_next = factor.next;
  var cont = {
    next: function() {
      factor.next = old_next;
      next();
    },
    cont: factor.cont
  };
  new_cont.data_stack.push(cont);
  factor.cont = new_cont;;
  quot.execute(next);  
});

factor.words["continue"] = new Word("continue", "primitive", function(next) {  
  var data_stack = factor.cont.data_stack;
  var cont = data_stack.pop(); 
  factor.cont = cont.cont.clone();
  (cont.next)();
});

factor.words["alien-invoke"] = new Word("alien-invoke", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
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
  next();
});

Factor.prototype.push_data = function(v, next) {
  factor.cont.data_stack.push(v);
  next();
}

Factor.prototype.define_word = function(name, source, func, next) {
  factor.words[name] = new Word(name, source, function(next) {
    var old = factor.next;
    factor.next = function() {
      factor.next = old;
      next();
    }
    func();
  });
  next();
}

Factor.prototype.make_quotation = function(source, func) {
  return new Word("quotation", source, function(next) {
    var old = factor.next;
    factor.next = function() {
      factor.next = old;
      next();
    }
    func();
  });
}

Factor.prototype.server_eval = function(text, next) {
   var self = this;
   var callback = {
      success: function(o) {
	 var v = o.responseText;
	 document.getElementById('compiled').innerHTML="<pre>" + v + "</pre>";
	 document.getElementById('code').value="";
	 var func = eval(v);
         factor.next = function() { self.display_datastack(); } 
	 func(factor);
         if(next) 
           next();
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