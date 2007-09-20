
USING: kernel parser generic math sequences strings ;

IN: lisp.lexer

TUPLE: sexp-lexer ;

: <sexp-lexer> ( text -- lexer )
    <lexer> sexp-lexer construct-delegate ;

M: sexp-lexer skip-word ( lexer -- )
[ 2dup nth "\"()" member?
  [ drop 1+ ] [ [ dup blank? swap ")" member? or ] skip ] if ] change-column ;