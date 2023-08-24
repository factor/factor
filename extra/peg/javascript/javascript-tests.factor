! Copyright (C) 2008 Chris Double.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors kernel math peg peg.ebnf peg.ebnf.private
peg.javascript peg.javascript.private sequences tools.test ;

{
  V{
    T{ ast-number f 123 }
    ";"
    T{ ast-string f "hello" }
    ";"
    T{ ast-name f "foo" }
    "("
    T{ ast-name f "x" }
    ")"
    ";"
  }
} [
  "123; 'hello'; foo(x);" tokenize-javascript
] unit-test

{ V{ T{ ast-regexp f "<(w+)[^>]*?)/>" "g" } } } [
  "/<(\\w+)[^>]*?)\\/>/g" tokenize-javascript
] unit-test

{
    V{ T{ ast-string { value "abc\"def\"" } } }
} [ "\"abc\\\"def\\\"\"" tokenize-javascript ] unit-test

{
    V{ T{ ast-string { value "\b\f\n\r\t\v'\"\\" } } }
} [ "\"\\b\\f\\n\\r\\t\\v\\'\\\"\\\\\"" tokenize-javascript ] unit-test

{
    V{ T{ ast-string { value "abc" } } }
} [ "\"\\x61\\u0062\\u{63}\"" tokenize-javascript ] unit-test

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
  "123; 'hello'; foo(x);" parse-javascript
] unit-test

{ t } [
"
var x=5
var y=10
" main \ parse-javascript rule (parse) remaining>> length zero?
] unit-test


{ t } [
"
function foldl(f, initial, seq) {
   for(var i=0; i< seq.length; ++i)
     initial = f(initial, seq[i]);
   return initial;
}" main \ parse-javascript rule (parse) remaining>> length zero?
] unit-test

{ t } [
"
ParseState.prototype.from = function(index) {
    var r = new ParseState(this.input, this.index + index);
    r.cache = this.cache;
    r.length = this.length - index;
    return r;
}" main \ parse-javascript rule (parse) remaining>> length zero?
] unit-test


{ T{ ast-begin f V{ T{ ast-number f 123 } } } } [
  "123;" parse-javascript
] unit-test
