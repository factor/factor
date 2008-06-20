! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.javascript.ast peg.javascript.tokenizer  
       peg.javascript.parser accessors multiline sequences math ;
IN: peg.javascript.parser.tests

\ parse-javascript must-infer

{
  T{
      ast-begin
      f
      V{
          T{ ast-number f 123 }
          T{ ast-string f "hello" }
          T{
              ast-call
              f
              T{ ast-get f "foo" }
              V{ T{ ast-get f "x" } }
          }
      }
  }
} [
  "123; 'hello'; foo(x);" tokenize-javascript ast>> parse-javascript ast>>
] unit-test

{ t } [ 
<"
var x=5
var y=10
"> tokenize-javascript ast>> parse-javascript remaining>> length zero?
] unit-test


{ t } [ 
<"
function foldl(f, initial, seq) {
   for(var i=0; i< seq.length; ++i)
     initial = f(initial, seq[i]);
   return initial;
}
"> tokenize-javascript ast>> parse-javascript remaining>> length zero?
] unit-test

{ t } [ 
<"
ParseState.prototype.from = function(index) {
    var r = new ParseState(this.input, this.index + index);
    r.cache = this.cache;
    r.length = this.length - index;
    return r;
}
"> tokenize-javascript ast>> parse-javascript remaining>> length zero?
] unit-test

