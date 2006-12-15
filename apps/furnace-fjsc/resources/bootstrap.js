function Factor() {
  var self = this;
  this.form = false;
  this.data_stack = [ ];  
  this.words = { 
    dup: function() { self.fjsc_dup(); },
    drop: function() { self.fjsc_drop(); },
    nip: function() { self.fjsc_nip(); },
    over: function() { self.fjsc_over(); },
    swap: function() { self.fjsc_swap(); },
    "+": function() { self.fjsc_plus(); },
    "-": function() { self.fjsc_minus(); },
    "*": function() { self.fjsc_times(); },
    "/": function() { self.fjsc_divide(); },
    ".": function() { self.fjsc_dot(); },
    "call": function() { self.fjsc_call(); },
    "execute": function() { self.fjsc_call(); },
    "map": function() { self.fjsc_map(); },
    "reduce": function() { self.fjsc_reduce(); },
    "clear": function() { self.fjsc_clear(); },
    "if": function() { self.fjsc_if(); },
    "=": function() { self.fjsc_equals(); },
    "f": function() { self.fjsc_false(); },
    "t": function() { self.fjsc_true(); },
    "empty?": function() { self.fjsc_is_empty(); },
    "window": function() { self.fjsc_window(); },
    "run-file": function() { self.fjsc_run_file(); },
    "http-get": function() { self.fjsc_http_get(); },
    "bootstrap": function() { self.fjsc_bootstrap(); }
  };  
}

Factor.prototype.server_eval = function(text) {
   var self = this;
   var callback = {
      success: function(o) {
	 var v = o.responseText;
	 eval(v)
	 self.display_datastack();
	 document.getElementById('compiled').innerHTML="<pre>" + v + "</pre>";
	 document.getElementById('code').value="";
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
   for(var i = 0; i < this.data_stack.length; ++i) {
      html.push("<tr><td>")
      html.push(this.data_stack[i])
      html.push("</td></tr>")
   }
   html.push("</table>")
   document.getElementById('stack').innerHTML=html.join("");
}

Factor.prototype.fjsc_dup = function() {
  var stack = this.data_stack;
   var v = stack.pop();
   stack.push(v);
   stack.push(v);
}

Factor.prototype.fjsc_drop = function() {
  this.data_stack.pop();
}

Factor.prototype.fjsc_nip = function() {
  var stack = this.data_stack;
  var v = stack.pop();
  stack.pop();
  stack.push(v);
}

Factor.prototype.fjsc_plus = function() {
  var stack = this.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v1+v2);
}

Factor.prototype.fjsc_minus = function() {
  var stack = this.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2-v1);
}

Factor.prototype.fjsc_times = function() {
  var stack = this.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v1*v2);
}

Factor.prototype.fjsc_divide = function() {
  var stack = this.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2/v1);
}

Factor.prototype.fjsc_dot = function() {
  alert(this.data_stack.pop());
}

Factor.prototype.fjsc_call = function() {
  (this.data_stack.pop())();
}

Factor.prototype.fjsc_map = function() {
  var quot = this.data_stack.pop();
  var seq = this.data_stack.pop();
  var result = [ ];
  for(var i=0;i<seq.length;++i) {  
    this.data_stack.push(seq[i]);
    (quot)();
    result[i]=this.data_stack.pop();
  }
  this.data_stack.push(result);
}

Factor.prototype.fjsc_reduce = function() {
  var quot = this.data_stack.pop();
  var prev = this.data_stack.pop();
  var seq = this.data_stack.pop();
  for(var i=0;i<seq.length;++i) {  
    this.data_stack.push(prev);
    this.data_stack.push(seq[i]);
    (quot)();
    prev=this.data_stack.pop();
  }
  this.data_stack.push(prev);
}

Factor.prototype.fjsc_if = function() {
  var else_quot = this.data_stack.pop();
  var then_quot = this.data_stack.pop();
  var condition = this.data_stack.pop();
  if(condition) {
    (then_quot)();
  } else {
    (else_quot)();
  }
}

Factor.prototype.fjsc_equals = function() {
  var v1 = this.data_stack.pop();
  var v2 = this.data_stack.pop();
  this.data_stack.push(v1==v2);
}

Factor.prototype.fjsc_clear = function() {
  factor.data_stack = [ ]
}

Factor.prototype.fjsc_false = function() {
  factor.data_stack.push(false);
}

Factor.prototype.fjsc_true = function() {
  factor.data_stack.push(true);
}

Factor.prototype.fjsc_is_empty = function() {
  factor.data_stack.push(factor.data_stack.pop().length==0);
}

Factor.prototype.fjsc_over = function() {
   var stack = this.data_stack;
   stack.push(stack[stack.length-2]);
}

Factor.prototype.fjsc_swap = function() {
   var stack = this.data_stack; 
   var len = stack.length;
   var temp = stack[len-2];   
   stack[len-2] = stack[len-1];
   stack[len-1] = temp;
}

Factor.prototype.fjsc_window = function() {
   var stack = this.data_stack;
   stack.push(window);
}

Factor.prototype.fjsc_run_file = function() {
   var self = this;
   var stack = this.data_stack;
   var url = stack.pop();
   var callback = {
     success: function(o) {
       var result = o.responseText;
       self.server_eval(result);
     },
     failure: function(o) {
       alert('run-file failed');
     }
   };

   YAHOO.util.Connect.asyncRequest('GET', url, callback, null);
}

Factor.prototype.fjsc_http_get = function() {
   var self = this;
   var stack = this.data_stack;
   var url = stack.pop();
   var callback = {
     success: function(o) {
       var result = o.responseText;
       self.data_stack.push(result);
       self.display_datastack();
     },
     failure: function(o) {
       alert('http-get failed');
     }
   };

   YAHOO.util.Connect.asyncRequest('GET', url, callback, null);
}


Factor.prototype.fjsc_bootstrap = function() {
   this.data_stack.push("/responder/fjsc-resources/bootstrap.factor");
   this.fjsc_run_file();
}

var factor = new Factor();