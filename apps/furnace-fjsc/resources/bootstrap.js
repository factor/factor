function Factor() {
  var self = this;
  this.data_stack = [ ];  
  this.words = { 
    dup: function() { self.fjsc_dup() },
    drop: function() { self.fjsc_drop() },
    alert: function() { self.fjsc_alert() }
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

Factor.prototype.fjsc_dup = function() {
  var stack = this.data_stack;
   var v = stack.pop();
   stack.push(v);
   stack.push(v);
}

Factor.prototype.fjsc_drop = function() {
  this.data_stack.pop();
}

Factor.prototype.fjsc_alert = function() {
  alert(this.data_stack.pop());
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

var factor = new Factor();