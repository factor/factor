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

: rtrim* ( seq quot -- newseq )
    2dup >r last r> call [ >r dup length 1- head-slice r> rtrim* ] [ drop ] if ;
: rtrim ( seq -- newseq ) [ blank? ] rtrim* ;

: ltrim* ( seq quot -- newseq )
    2dup >r first r> call [ >r 1 tail-slice r> ltrim* ] [ drop ] if ;
: ltrim ( seq -- newseq ) [ blank? ] ltrim* ;

: trim* ( seq quot -- newseq ) [ ltrim* ] keep rtrim* ;
: trim ( seq -- newseq ) [ blank? ] trim* ;

PROVIDE: contrib/sequences ;
