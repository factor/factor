USING: combinators.lib kernel sequences math namespaces assocs 
random sequences.private shuffle math.functions mirrors ;
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
    [ drop /mod ] curry* map nip  ;

: map-alphabet ( alphabet seq[seq] -- seq[seq] )
    [ [ swap nth ] curry* map ] curry* map ;

: exact-number-strings ( n out-len -- seqs )
    [ ^ ] 2keep [ translate-string ] 2curry map ;

: number-strings ( n max-length -- seqs )
    1+ [ exact-number-strings ] curry* map concat ;
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
