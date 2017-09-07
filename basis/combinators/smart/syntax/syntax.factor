! Copyright (C) 2017 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.smart fry kernel parser sequences
sequences.generalizations ;
IN: combinators.smart.syntax

SYNTAX: \quotation[ parse-quotation '[ _ [ ] output>sequence ] append! ;
SYNTAX: \'quotation[ parse-quotation '[ _ fry call [ ] output>sequence ] append! ;

SYNTAX: \array[ parse-quotation '[ _ { } output>sequence ] append! ;
SYNTAX: \'array[ parse-quotation '[ _ fry call { } output>sequence ] append! ;

SYNTAX: \vector[ parse-quotation '[ _ V{ } output>sequence ] append! ;
SYNTAX: \'vector[ parse-quotation '[ _ fry call V{ } output>sequence ] append! ;

SYNTAX: \assoc[ parse-quotation '[ _ { } output>assoc ] append! ;
SYNTAX: \'assoc[ parse-quotation '[ _ fry call { } output>assoc ] append! ;

SYNTAX: \hashtable[ parse-quotation '[ _ H{ } output>assoc ] append! ;
SYNTAX: \'hashtable[ parse-quotation '[ _ fry call H{ } output>assoc ] append! ;

ERROR: wrong-number-of-outputs quot expected got ;
: check-outputs ( quot n -- quot )
    2dup [ outputs dup ] dip = [ 2drop ] [ wrong-number-of-outputs ] if ;

SYNTAX: \1[ parse-quotation 1 check-outputs '[ _ { } output>sequence 1 firstn ] append! ;
SYNTAX: \2[ parse-quotation 2 check-outputs '[ _ { } output>sequence 2 firstn ] append! ;
SYNTAX: \3[ parse-quotation 3 check-outputs '[ _ { } output>sequence 3 firstn ] append! ;
SYNTAX: \4[ parse-quotation 4 check-outputs '[ _ { } output>sequence 4 firstn ] append! ;
SYNTAX: \5[ parse-quotation 5 check-outputs '[ _ { } output>sequence 5 firstn ] append! ;
SYNTAX: \n[ parse-quotation 5 check-outputs '[ _ { } output>sequence 5 firstn ] append! ;

SYNTAX: \'1[ parse-quotation fry '[ _ call 1 check-outputs { } output>sequence 1 firstn ] append! ;
SYNTAX: \'2[ parse-quotation fry '[ _ call 2 check-outputs { } output>sequence 2 firstn ] append! ;
SYNTAX: \'3[ parse-quotation fry '[ _ call 3 check-outputs { } output>sequence 3 firstn ] append! ;
SYNTAX: \'4[ parse-quotation fry '[ _ call 4 check-outputs { } output>sequence 4 firstn ] append! ;
SYNTAX: \'5[ parse-quotation fry '[ _ call 5 check-outputs { } output>sequence 5 firstn ] append! ;
