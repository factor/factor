function fjsc_eval(form) {
   var callback = {
      success: function(o) {
	 var v = o.responseText;
	 eval(v)
	 display_datastack();
	 document.getElementById('compiled').innerHTML="<pre>" + v + "</pre>";
	 document.getElementById('code').value="";

      }
   };
   YAHOO.util.Connect.setForm(form);
   YAHOO.util.Connect.asyncRequest('POST', "/responder/fjsc/compile", callback);
}

var data_stack = [ ] 

function fjsc_dup() {
   var v = data_stack.pop();
   data_stack.push(v);
   data_stack.push(v);
}

function fjsc_drop() {
   data_stack.pop();
}

function fjsc_alert() {
   alert(data_stack.pop())
}

function display_datastack() {
   var html=[];
   html.push("<table border='1'>")
   for(var i = 0; i < data_stack.length; ++i) {
      html.push("<tr><td>")
      html.push(data_stack[i])
      html.push("</td></tr>")
   }
   html.push("</table>")
   document.getElementById('stack').innerHTML=html.join("");
}
