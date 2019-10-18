
USING: kernel parser namespaces io prettyprint math arrays sequences
       words listener debugger
       lisp lisp.lexer lisp.parser.mod lisp.listener.mod ;

IN: lisp.listener

: parse-stdio ( -- quot/f ) stdio get parse-interactive ;

: stuff? ( -- ? ) datastack length 0 > ;

: lisp-listen ( -- )
[ parse-stdio [ call stuff? [ eval ] when ] [ bye ] if* ] try ;

: until-quit ( -- )
quit-flag get
[ quit-flag off ]
[ listener-hook get call prompt. lisp-listen until-quit ]
if ;

: lisp-listener ( -- ) [
use [ clone ] change
[ <sexp-lexer> ] >listener-lexer
[ in get create dup define-symbol ] >new-symbol-action
{ "lisp" "lisp.syntax" } add-use
! [ listener-hook get call prompt. lisp-listen ] until-quit
until-quit
] with-scope ;