
USING: kernel parser generic math sequences strings ;

IN: lisp.lexer

TUPLE: sexp-lexer ;

C: sexp-lexer ( text -- lexer ) >r <lexer> r> tuck set-delegate ;

M: sexp-lexer skip-word ( lexer -- )
[ 2dup nth "\"()" member?
  [ drop 1+ ] [ [ dup blank? swap ")" member? or ] skip ] if ] change-column ;