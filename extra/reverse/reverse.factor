! Originally by John Benediktsson,
!   see: https://re.factorcode.org/2025/09/std-flip.html
! See https://factorcode.org/license.txt for BSD license.
USING: accessors effects generalizations kernel parser 
ranges sequences stack-checker ;
IN: reverse

MACRO: nreverse ( n -- quot )
    0 [a..b) [ '[ _ -nrot ] ] map [ ] concat-as ;

: flip-word ( word -- quot ) 
   [ stack-effect in>> length ] keep
   '[ _ nreverse _ execute ] ;

SYNTAX: flip:
    scan-word flip-word append! ;

: flip-quot ( quot -- quot )
   [ infer in>> length ] keep '[ _ nreverse @ ] ;

SYNTAX: flip[
    parse-quotation flip-quot suffix! ;
