USING: combinators.lib kernel sequences math namespaces assocs 
random sequences.private shuffle math.functions mirrors ;
USING: arrays math.parser sorting strings ;
IN: sequences.lib

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: map-reduce ( seq map-quot reduce-quot -- result )
    >r [ unclip ] dip [ call ] keep r> compose reduce ; inline

: reduce* ( seq quot -- result ) [ ] swap map-reduce ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: higher ( a b quot -- c ) [ compare 0 > ] curry most ; inline

: lower  ( a b quot -- c ) [ compare 0 < ] curry most ; inline

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longer  ( a b -- c ) [ length ] higher ;

: shorter ( a b -- c ) [ length ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: longest ( seq -- item ) [ longer ] reduce* ;

: shortest ( seq -- item ) [ shorter ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bigger ( a b -- c ) [ ] higher ;

: smaller ( a b -- c ) [ ] lower ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: biggest ( seq -- item ) [ bigger ] reduce* ;

: smallest ( seq -- item ) [ smaller ] reduce* ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: minmax ( seq -- min max )
    #! find the min and max of a seq in one pass
    1/0. -1/0. rot [ tuck max >r min r> ] each ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ,, building get peek push ;
: v, V{ } clone , ;
: ,v building get dup peek empty? [ dup pop* ] when drop ;

: monotonic-split ( seq quot -- newseq )
    [
        >r dup unclip add r>
        v, [ pick ,, call [ v, ] unless ] curry 2each ,v
    ] { } make ;

: singleton? ( seq -- ? )
    length 1 = ;

: delete-random ( seq -- value )
    [ length random ] keep [ nth ] 2keep delete-nth ;

: split-around ( seq quot -- before elem after )
    dupd find over [ "Element not found" throw ] unless
    >r cut-slice 1 tail r> swap ; inline

: (map-until) ( quot pred -- quot )
    [ dup ] swap 3compose
    [ [ drop t ] [ , f ] if ] compose [ find 2drop ] curry ;

: map-until ( seq quot pred -- newseq )
    (map-until) { } make ;

: take-while ( seq quot -- newseq )
    [ not ] compose
    [ find drop [ head-slice ] when* ] curry
    [ dup ] swap compose keep like ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<PRIVATE
: translate-string ( n alphabet out-len -- seq )
    [ drop /mod ] with map nip  ;

: map-alphabet ( alphabet seq[seq] -- seq[seq] )
    [ [ swap nth ] with map ] with map ;

: exact-number-strings ( n out-len -- seqs )
    [ ^ ] 2keep [ translate-string ] 2curry map ;

: number-strings ( n max-length -- seqs )
    1+ [ exact-number-strings ] with map concat ;
PRIVATE>

: exact-strings ( alphabet length -- seqs )
    >r dup length r> exact-number-strings map-alphabet ;

: strings ( alphabet length -- seqs )
    >r dup length r> number-strings map-alphabet ;

: nths ( nths seq -- subseq )
    ! nths is a sequence of ones and zeroes
    >r [ length ] keep [ nth 1 = ] curry subset r>
    [ nth ] curry { } map-as ;

: power-set ( seq -- subsets )
    2 over length exact-number-strings swap [ nths ] curry map ;

: push-either ( elt quot accum1 accum2 -- )
    >r >r keep swap r> r> ? push ; inline

: 2pusher ( quot -- quot accum1 accum2 )
    V{ } clone V{ } clone [ [ push-either ] 3curry ] 2keep ; inline

: partition ( seq quot -- trueseq falseseq )
    over >r 2pusher >r >r each r> r> r> drop ; inline

: cut-find ( seq pred -- before after )
    dupd find drop dup [ cut ] when ;

: cut3 ( seq pred -- first mid last )
    [ cut-find ] keep [ not ] compose cut-find ;

: (cut-all) ( seq pred quot -- )
    [ >r cut3 r> dip >r >r , r> [ , ] when* r> ] 2keep
    pick [ (cut-all) ] [ 3drop ] if ;

: cut-all ( seq pred quot -- first mid last )
    [ (cut-all) ] { } make ;

: human-sort ( seq -- newseq )
    [ dup [ digit? ] [ string>number ] cut-all ] { } map>assoc
    sort-values keys ;

: ?first ( seq -- first/f ) 0 swap ?nth ; inline
: ?second ( seq -- second/f ) 1 swap ?nth ; inline
: ?third ( seq -- third/f ) 2 swap ?nth ; inline
: ?fourth ( seq -- fourth/f ) 3 swap ?nth ; inline
