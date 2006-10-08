USING: kernel math sequences strings ;
IN: sequences-contrib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: 3nth ( n seq -- slice ) >r dup 3 + r> <slice> ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map3-i ( seq -- i ) length 2 - ;

: map3-quot ( quot -- quot ) [ swap 3nth ] swap append ;

: map3 ( seq quot -- seq ) over map3-i swap map3-quot map-with ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: last ( seq -- elt ) [ length 1- ] keep nth ;

: (rtrim*) ( seq quot -- newseq )
    over length 0 > [
        2dup >r last r> call
        [ >r dup length 1- head-slice r> (rtrim*) ] [ drop ] if
    ] [
        drop
    ] if ;
: rtrim* ( seq quot -- newseq ) [ (rtrim*) ] 2keep drop like ;
: rtrim ( seq -- newseq ) [ blank? ] rtrim* ;

: (ltrim*) ( seq quot -- newseq )
    over length 0 > [
        2dup >r first r> call [ >r 1 tail-slice r> (ltrim*) ] [ drop ] if
    ] [
        drop
    ] if ;
: ltrim* ( seq quot -- newseq ) [ (ltrim*) ] 2keep drop like ;
: ltrim ( seq -- newseq ) [ blank? ] ltrim* ;

: trim* ( seq quot -- newseq ) [ (ltrim*) ] keep rtrim* ;
: trim ( seq -- newseq ) [ blank? ] trim* ;

: ?head-slice ( seq begin -- newseq ? )
  2dup head? [ length tail-slice t ] [ drop f ] if ;

: ?tail-slice ( seq end -- newseq ? )
  2dup tail? [ length head-slice* t ] [ drop f ] if ;

: unclip-slice ( seq -- rest first )
  dup 1 tail-slice swap first ;

PROVIDE: contrib/sequences ;
