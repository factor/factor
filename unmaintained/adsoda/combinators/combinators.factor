! Copyright (C) 2008 Jeff Bigot
! See http://factorcode.org/license.txt for BSD license.
USING: kernel arrays sequences fry math combinators ;

IN: adsoda.combinators

! : (combinations) ( seq -- seq ) [ 1 tail ] dip combinations ;

! : prefix-each [ prefix ] curry map ; inline

! : combinations ( seq n -- seqs )
!    {
!        { [ dup 0 = ] [ 2drop { { } } ] }
!        { [ over empty? ] [ 2drop { } ] }
!        { [ t ] [ 
!            [ [ 1 - (combinations) ] [ drop first ] 2bi prefix-each ]
!            [ (combinations) ] 2bi append
!        ] }
!    } cond ;

: columnize ( array -- array ) [ 1array ] map ; inline

: among ( array n -- array )
    2dup swap length 
    {
        { [ over 1 = ] [ 3drop columnize ] }
        { [ over 0 = ] [ 4drop { } ] }
        { [ 2dup < ] [ 2drop [ 1 cut ] dip
                         [ 1 - among [ append ] with map ]
                         [ among append ] 2bi
                       ] }
        { [ 2dup = ] [ 3drop 1array ] }
        { [ 2dup > ] [ 4drop { } ] }
    } cond
;

: concat-nth ( seq1 seq2 -- seq )
    [ nth append ] curry map-index ;

: do-cycle   ( array -- array )   dup first suffix ;

: map-but ( seq i quot -- seq )
    ! quot : ( seq x -- seq )
    '[ _ = [ @ ] unless ] map-index ; inline

