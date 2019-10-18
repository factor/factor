
USING: kernel errors parser namespaces io prettyprint math arrays sequences
       words listener lisp lisp.lexer lisp.parser.mod lisp.listener.mod ;

IN: lisp.listener

: parse-stdio ( -- quot/f ) stdio get parse-interactive ;

: stuff? ( -- ? ) datastack length 0 > ;

: lisp-listen ( -- )
[ parse-stdio [ call stuff? [ eval ] when ] [ bye ] if* ] try ;

: lisp-listener ( -- ) [
use [ clone ] change
[ <sexp-lexer> ] >listener-lexer
[ in get create dup define-symbol ] >new-symbol-action
{ "lisp" "lisp.syntax" } add-use
[ listener-hook get call prompt. lisp-listen ] until-quit
] with-scope ;