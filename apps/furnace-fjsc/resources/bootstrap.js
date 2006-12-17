function Word(vocab, name, source, func) {
  this.vocab = vocab;
  this.name = name;
  this.source = source;
  this.func = func;
}

Word.prototype.execute = function(next) {
  this.func(next);
}

Word.prototype.toString = function() {
  var html = [];
  html.push("<a href='/responder/browser/browse?vocab=")
  html.push(this.vocab);
  html.push("&amp;word=")
  html.push(this.name);
  html.push("'>")
  html.push(this.name);
  html.push("</a>");
  return html.join("");
}

function Continuation() {
  this.data_stack = [ ];
  this.retain_stack = [ ];
  this.next = false;
  this.nesting = 0;
}

Continuation.prototype.clone = function() {
  var c = new Continuation();
  c.data_stack = this.data_stack.slice(0);
  c.retain_stack = this.retain_stack.slice(0);
  c.nesting = this.nesting;
  c.next = this.next;
  return c;
}

function Factor() {
  this.vocabs = { scratchpad: { } };
  this.in_vocab = "scratchpad";
  this.using_vocabs = [ "scratchpad", "kernel","math","sequences","parser","alien","browser-dom", "words" ];
  this.cont = new Continuation();
}

var factor = new Factor();

Factor.prototype.call_next = function(next) {
  if(next) {
    if(this.cont.nesting++ > 150) {
      this.cont.nesting = 0;
      setTimeout(next, 0);
   }
    else {
      next();
    }
  }
}

Factor.prototype.push_data = function(v, next) {
  factor.cont.data_stack.push(v);
  factor.call_next(next);
}

Factor.prototype.get_word = function(vocab,name) {
  return factor.vocabs[vocab][name];
}

Factor.prototype.find_word = function(name) {
  for(var v = 0; v<factor.using_vocabs.length; ++v) {
    var w = factor.vocabs[factor.using_vocabs[v]][name];
    if(w)
      return w;
  }
  return false;
}

Factor.prototype.add_word = function(vocab,name, source, func) {
  var v = factor.vocabs[vocab];
  if(!v) {
    v = { };
    factor.vocabs[vocab] = v;
  }
  v[name] = new Word(vocab,name,source,func);
}

Factor.prototype.remove_word = function(vocab,name) {
  var v = factor.vocabs[vocab];
  if(!v) {
    v = { };
    factor.vocabs[vocab] = v;
  }
  delete v[name];
}
    
Factor.prototype.define_word = function(name, source, func, next) {
  factor.vocabs[factor.in_vocab][name] = new Word(factor.in_vocab, name, source, function(next) {
    var old = factor.cont.next;
    factor.cont.next = function() {
      factor.cont.next = old;
      factor.call_next(next);
    }
    func();
  });
  factor.call_next(next);
}

Factor.prototype.make_quotation = function(source, func) {
  return new Word("quotations", "quotation", source, function(next) {
    var old = factor.cont.next;
    factor.cont.next = function() {
      factor.cont.next = old;
      factor.call_next(next);
    }
    func();
  });
}

Factor.prototype.server_eval = function(text, next) {
   var self = this;
   $.post("/responder/fjsc/compile", { code: text }, function(result) {
     document.getElementById('compiled').innerHTML="<pre>" + result + "</pre>";
     document.getElementById('code').value="";
     var func = eval(result);
     factor.cont.next = function() { self.display_datastack(); } 
     func(factor);
     if(next) 
       factor.call_next(next);
   });
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

/* Kernel Vocabulary */
factor.add_word("kernel","dup", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length] = stack[stack.length-1];
  factor.call_next(next);
});

factor.add_word("kernel", "drop", "primitive", function(next) {
  factor.cont.data_stack.pop();
  factor.call_next(next);
});

factor.add_word("kernel", "nip", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length-2] = stack[stack.length-1];
  stack.pop();
  factor.call_next(next);
});

factor.add_word("kernel", "over", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack[stack.length] = stack[stack.length-2];
  factor.call_next(next);
});

factor.add_word("kernel", "swap", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var temp = stack[stack.length-2];
  stack[stack.length-2] = stack[stack.length-1];
  stack[stack.length-1] = temp;
  factor.call_next(next);
});

factor.add_word("kernel", ">r", "primitive", function(next) {
  var data_stack = factor.cont.data_stack;
  var retain_stack = factor.cont.retain_stack;
  retain_stack.push(data_stack.pop());
  factor.call_next(next);
});

factor.add_word("kernel", "r>", "primitive", function(next) {
  var data_stack = factor.cont.data_stack;
  var retain_stack = factor.cont.retain_stack;
  data_stack.push(retain_stack.pop());
  factor.call_next(next);
});

factor.add_word("kernel", "call", "primitive", function(next) {
  var quot = factor.cont.data_stack.pop();
  quot.execute(next);
});

factor.add_word("kernel", "execute", "primitive", function(next) {
  var quot = factor.cont.data_stack.pop();
  quot.execute(next);
});

factor.add_word("kernel", "clear", "primitive", function(next) {
  factor.cont.data_stack = [];
  factor.cont.retain_stack = [];
  factor.call_next(next);
});

factor.add_word("kernel", "if", "primitive", function(next) {  
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

factor.add_word("kernel", "f", "primitive", function(next) {  
  factor.cont.data_stack.push(false);
  factor.call_next(next);
});

factor.add_word("kernel", "t", "primitive", function(next) {  
  factor.cont.data_stack.push(true);
  factor.call_next(next);
});

factor.add_word("kernel", "=", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  stack.push(stack.pop()==stack.pop());
  factor.call_next(next);
});

factor.add_word("kernel", "bootstrap", "primitive", function(next) {  
  factor.cont.data_stack.push("/responder/fjsc-resources/bootstrap.factor");
  factor.get_word("parser", "run-file").execute(next);
});

factor.add_word("kernel", "callcc0", "primitive", function(next) {  
  var data_stack = factor.cont.data_stack;
  var quot = data_stack.pop();
  var new_cont = factor.cont.clone();  
  var old_next = factor.cont.next;
  factor.cont.next = function() {
      factor.cont.next = old_next;
      factor.call_next(next);
  }
  new_cont.data_stack.push(factor.cont);
  factor.cont = new_cont;
  quot.execute(next);  
});

factor.add_word("kernel", "callcc1", "primitive", function(next) {  
  factor.get_word("kernel", "callcc0").execute(next);
});

factor.add_word("kernel", "continue", "primitive", function(next) {  
  var data_stack = factor.cont.data_stack;
  var cont = data_stack.pop(); 
  factor.cont = cont.clone();
  factor.call_next(cont.next);
});

factor.add_word("kernel", "continue-with", "primitive", function(next) {  
  var data_stack = factor.cont.data_stack;
  var cont = data_stack.pop(); 
  var data = data_stack.pop(); 
  factor.cont = cont.clone();
  factor.cont.data_stack.push(data);
  factor.call_next(cont.next);
});

factor.add_word("kernel", "in", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var vocab = stack.pop();
  var v = factor.vocabs[vocab];
  if(!v) {
    v = { };
    factor.vocabs[vocab] = v;
  }
  factor.in_vocab = vocab;
  factor.call_next(next);  
});

factor.add_word("kernel", "current-vocab", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  stack.push(factor.in_vocab);
  factor.call_next(next);  
});

factor.add_word("kernel", "use", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var vocab = stack.pop();
  var v = factor.vocabs[vocab];
  if(!v) {
    v = { };
    factor.vocabs[vocab] = v;
  }
  factor.using_vocabs.push(vocab);
  factor.call_next(next);  
});

factor.add_word("kernel", "using", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var vocabs = stack.pop();
  factor.using_vocabs = [];
  for(var i=0;i<vocabs.length;++i) {  
    var v = factor.vocabs[vocabs[i]];
    if(!v) {
      v = { };
      factor.vocabs[vocabs[i]] = v;
    }
  }
  factor.using_vocabs = vocabs;
  factor.call_next(next);  
});

factor.add_word("kernel", "current-using", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  stack.push(factor.using_vocabs);
  factor.call_next(next);  
});

factor.add_word("kernel", "forget", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var word = stack.pop();
  factor.remove_word(word.vocab, word.name);
  factor.call_next(next);  
});

factor.add_word("kernel", ">function", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var word = stack.pop();
  stack.push(function() { word.func(function() { }) });
  factor.call_next(next);  
});

factor.add_word("kernel", "curry", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var quot = stack.pop();
  var value = stack.pop();
  
  stack.push(factor.make_quotation("quotation", function(next) {
    factor.cont.data_stack.push(value);   
    quot.execute(factor.cont.next);
  }));
  factor.call_next(next);
});

/* Math vocabulary */
factor.add_word("math", "*", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack.push(stack.pop() * stack.pop());
  factor.call_next(next);
});

factor.add_word("math", "+", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  stack.push(stack.pop() + stack.pop());
  factor.call_next(next);
});

factor.add_word("math", "-", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 - v1);
  factor.call_next(next);
});

factor.add_word("math", "/", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var v1 = stack.pop();
  var v2 = stack.pop();
  stack.push(v2 / v1);
  factor.call_next(next);
});

factor.add_word("prettyprint", ".", "primitive", function(next) {
  alert(factor.cont.data_stack.pop());
  factor.call_next(next);
});

factor.add_word("parser", "run-file", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  var url = stack.pop();
  $.get(url, function(result) {
    factor.server_eval(result, next);
  });
});


factor.add_word("alien", "alien-invoke", "primitive", function(next) {  
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
  var v = obj[method_name].apply(obj, args.reverse());
  if(return_values.length > 0)
    stack.push(v);
  factor.call_next(next);
});

factor.add_word("alien", "alien-property", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  var obj = stack.pop();
  var property_name = stack.pop();
  var v = obj[property_name];
  stack.push(v);
  factor.call_next(next);
});

factor.add_word("alien", "set-alien-property", "primitive", function(next) {  
  var stack = factor.cont.data_stack;
  var obj = stack.pop();
  var property_name = stack.pop();
  var data = stack.pop();
  obj[property_name] = v;
  factor.call_next(next);
});

factor.add_word("words", "vocabs", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var result = [];
  for(v in factor.vocabs) {
    result.push(v);
  }
  stack.push(result);
  factor.call_next(next);
});

factor.add_word("words", "words", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var vocab = factor.vocabs[stack.pop()];
  var result = [];
  for(w in vocab) {
    result.push(vocab[w]);
  }
  stack.push(result);
  factor.call_next(next);
});

factor.add_word("words", "all-words", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var result = [];
  for(v in factor.vocabs) {
    for(w in factor.vocabs[v]) {
      result.push(factor.vocabs[v][w]);
    }
  }
  stack.push(result);
  factor.call_next(next);
});

/* Sequences vocabulary */
factor.add_word("sequences", "nth", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  var index = stack.pop();
  stack.push(seq[index]);
  factor.call_next(next);
});

factor.add_word("sequences", "first", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[0]);
  factor.call_next(next);
});

factor.add_word("sequences", "second", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[1]);
  factor.call_next(next);
});

factor.add_word("sequences", "third", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[2]);
  factor.call_next(next);
});

factor.add_word("sequences", "fourth", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[0]);
  factor.call_next(next);
});

factor.add_word("sequences", "first2", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[0],seq[1]);
  factor.call_next(next);
});

factor.add_word("sequences", "first3", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[0],seq[1],seq[2]);
  factor.call_next(next);
});

factor.add_word("sequences", "first4", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var seq = stack.pop();
  stack.push(seq[0],seq[1],seq[2],seq[3]);
  factor.call_next(next);
});

factor.add_word("sequences", "each", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var quot = stack.pop();
  var seq = stack.pop();
  for(var i=0;i<seq.length;++i) {  
    stack.push(seq[i]);
    quot.execute();
  }
  factor.call_next(next);
});

factor.add_word("sequences", "map", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var quot = stack.pop();
  var seq = stack.pop();
  var result = [ ];
  for(var i=0;i<seq.length;++i) {  
    stack.push(seq[i]);
    quot.execute();
    result[i]=stack.pop();
  }
  stack.push(result);
  factor.call_next(next);
});

factor.add_word("sequences", "reduce", "primitive", function(next) {   
  var stack = factor.cont.data_stack;
  var quot = stack.pop();
  var prev = stack.pop();
  var seq = stack.pop();
  for(var i=0;i<seq.length;++i) {  
    stack.push(prev);
    stack.push(seq[i]);
    quot.execute();
    prev=stack.pop();
  }
  stack.push(prev);
  factor.call_next(next);
});

/* browser-dom vocab */
factor.add_word("browser-dom", "window", "primitive", function(next) {  
  factor.cont.data_stack.push(window);
  factor.call_next(next);
});

factor.add_word("browser-dom", "document", "primitive", function(next) {  
  factor.cont.data_stack.push(document);
  factor.call_next(next);
});

/* Run initial factor code */
$(document).ready(function() {
  $.get("/responder/fjsc-resources/bootstrap.factor", function(result) {
    factor.server_eval(result, function() { });
  });
});
