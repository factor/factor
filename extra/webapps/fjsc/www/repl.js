/* Copyright (C) 2007 Chris Double. All Rights Reserved.
   See https://factorcode.org/license.txt for BSD license. */

var fjsc_repl = false;

function fjsc_repl_handler() {
  var my_term = this;
  this.newLine();
  if(this.lineBuffer != '') {
    factor.server_eval(
      this.lineBuffer,
      function(text, result) {
        document.getElementById("compiled").value = result;
        display_datastack();
      },
      function() { my_term.prompt(); });
  }
  else
    my_term.prompt();
}

function fjsc_init_handler() {
  this.write(
    [
      TermGlobals.center('********************************************************'),
      TermGlobals.center('*                                                      *'),
      TermGlobals.center('*       Factor to Javascript Compiler Example          *'),
      TermGlobals.center('*                                                      *'),
      TermGlobals.center('********************************************************')
    ]);

  this.prompt();
}

function startup() {
  var conf = {
    x: 0,
    y: 0,
    cols: 64,
    rows: 18,
    termDiv: "repl",
    crsrBlinkMode: true,
    ps: "( scratchpad )",
    initHandler: fjsc_init_handler,
    handler: fjsc_repl_handler
  };
  fjsc_repl = new Terminal(conf);
  fjsc_repl.open();
}

function display_datastack() {
   var html=[];
   html.push("<table border='1'>")
   for(var i = 0; i < factor.cont.data_stack.length; ++i) {
      html.push("<tr><td>")
      html.push(factor.cont.data_stack[i])
      html.push("</td></tr>")
   }
   html.push("</table>")
   document.getElementById('stack').innerHTML=html.join("");
}

jQuery(function() {
  startup();
  display_datastack();
});

factor.add_word("kernel", ".s", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var term = fjsc_repl;
  for(var i=0; i<stack.length; ++i) {
    term.type(""+stack[i]);
    term.newLine();
  }
  factor.call_next(next);
});

factor.add_word("io", "print", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var term = fjsc_repl;
  term.type(""+stack.pop());
  term.newLine();
  factor.call_next(next);
});

factor.add_word("io", "write", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var term = fjsc_repl;
  term.type(""+stack.pop());
  factor.call_next(next);
});

factor.add_word("io", ".", "primitive", function(next) {
  var stack = factor.cont.data_stack;
  var term = fjsc_repl;
  term.type(""+stack.pop());
  term.newLine();
  factor.call_next(next);
});
