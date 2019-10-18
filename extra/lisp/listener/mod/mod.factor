! Broken by recent changes

USING: kernel continuations namespaces parser combinators tuples generic vars ;
! 
IN: listener
! 
! ! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
! 
VAR: listener-lexer
! 
! [ <lexer> ] listener-lexer set-global
! 
! : listener-parse-lines ( lines -- quot ) listener-lexer> call (parse-lines) ;
! 
! : parse-interactive-step ( lines -- quot/f )
! [ listener-parse-lines ] catch {
!     { [ dup [ unexpected-eof? ] is? ] [ 2drop f ] }
!     { [ dup not ]		      [ drop ] }
!     { [ t ]	    		      [ rethrow ] }
! } cond ;
