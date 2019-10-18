! Based on lisp code from newsgroup discussion in
! comp.lang.lisp

!  (loop for y from -1 to 1.1 by 0.1 do
!        (loop for x from -2 to 1 by 0.04 do
!              (let* ((c 126)
!                     (z (complex x y))
!                     (a z))
!                (loop while (< (abs
!                                (setq z (+ (* z z) a)))
!                               2)
!                  while (> (decf c) 32)) 
!                (princ (code-char c))))
!        (format t "~%"))

USE: combinators
USE: math
USE: prettyprint
USE: stack
USE: stdio
USE: strings

: ?mandel-step ( a z c -- a z c ? )
    >r dupd sq + dup abs 2 < [
        r> pred dup CHAR: \s >
    ] [
        r> f
    ] ifte ;

: mandel-step ( a z c -- )
    [ ?mandel-step ] [ ] while >char write 2drop ;

: mandel-x ( x y -- )
    rect> dup CHAR: ~ mandel-step ;

: mandel-y ( y -- )
    150 [ dupd 50 / 2 - >float swap mandel-x ] times* drop ;

: mandel ( -- )
    42 [ 20 / 1 - >float mandel-y terpri ] times* ;
