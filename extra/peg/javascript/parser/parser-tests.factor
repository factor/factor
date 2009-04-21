! Copyright (C) 2008 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
!
USING: kernel tools.test peg peg.javascript.ast peg.javascript.parser 
       accessors multiline sequences math peg.ebnf ;
IN: peg.javascript.parser.tests

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
  "123; 'hello'; foo(x);" javascript
] unit-test

{ t } [ 
<"
var x=5
var y=10
"> main \ javascript rule (parse) remaining>> length zero?
] unit-test


{ t } [ 
<"
function foldl(f, initial, seq) {
   for(var i=0; i< seq.length; ++i)
     initial = f(initial, seq[i]);
   return initial;
}"> main \ javascript rule (parse) remaining>> length zero?
] unit-test

{ t } [ 
<"
ParseState.prototype.from = function(index) {
    var r = new ParseState(this.input, this.index + index);
    r.cache = this.cache;
    r.length = this.length - index;
    return r;
}"> main \ javascript rule (parse) remaining>> length zero?
] unit-test

