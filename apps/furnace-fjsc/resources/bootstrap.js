function Factor() {
  var self = this;
  this.data_stack = [ ];  
  this.words = { 
    dup: function() { self.fjsc_dup(); },
    drop: function() { self.fjsc_drop(); },
    nip: function() { self.fjsc_nip(); },
    "+": function() { self.fjsc_plus(); },
    "-": function() { self.fjsc_minus(); },
    "*": function() { self.fjsc_times(); },
    "/": function() { self.fjsc_divide(); },
    alert: function() { self.fjsc_alert(); }
  };  
}

Factor.prototype.fjsc_eval = function(form) {
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
   YAHOO.util.Connect.setForm(form);
   YAHOO.util.Connect.asyncRequest('POST', "/responder/fjsc/compile", callback);
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
  stack.push(v1-v2);
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

Factor.prototype.fjsc_alert = function() {
  alert(this.data_stack.pop());
}


var factor = new Factor();