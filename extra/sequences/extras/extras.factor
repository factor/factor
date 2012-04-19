USING: arrays grouping kernel locals math math.order math.ranges
sequences splitting ;

IN: sequences.extras

: reduce1 ( seq quot -- result ) [ unclip ] dip reduce ; inline

:: reduce-r
    ( list identity quot: ( obj1 obj2 -- obj ) -- result )
    list empty?
    [ identity ]
    [ list rest identity quot reduce-r list first quot call ] if ;
    inline recursive

! Quot must have static stack effect, unlike "reduce"
:: reduce* ( seq id quot -- result ) seq
    [ id ]
    [ unclip id swap quot call( prev elt -- next ) quot reduce* ] if-empty ; inline recursive

:: combos ( list1 list2 -- result ) list2 [ [ 2array ] curry list1 swap map ] map concat ;
: find-all ( seq quot -- elts ) [ [ length iota ] keep ] dip
    [ dupd call( a -- ? ) [ 2array ] [ 2drop f ] if ] curry 2map [ ] filter ; inline

: insert-sorted ( elt seq -- seq ) 2dup [ < ] with find drop over length or swap insert-nth ;

: max-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ max ] keep eq? not ] curry most ; inline

: min-by ( obj1 obj2 quot: ( obj -- n ) -- obj1/obj2 )
    [ bi@ [ min ] keep eq? not ] curry most ; inline

: maximum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ dup ?first ] dip [ max-by ] curry reduce ; inline

: minimum ( seq quot: ( ... elt -- ... x ) -- elt )
    [ dup ?first ] dip [ min-by ] curry reduce ; inline

: all-subseqs ( seq -- seqs )
    dup length [1,b] [ <clumps> ] with map concat ;

:: each-subseq ( ... seq quot: ( ... x -- ... ) -- ... )
    seq length [0,b] [
        :> from
        from seq length (a,b] [
            :> to
            from to seq subseq quot call( x -- )
        ] each
    ] each ;

:: longest-subseq ( seq1 seq2 -- subseq )
    seq1 length :> len1
    seq2 length :> len2
    0 :> n!
    0 :> end!
    len1 1 + [ len2 1 + 0 <array> ] replicate :> table
    len1 [1,b] [| x |
        len2 [1,b] [| y |
            x 1 - seq1 nth
            y 1 - seq2 nth = [
                y 1 - x 1 - table nth nth 1 + :> len
                len y x table nth set-nth
                len n > [ len n! x end! ] when
            ] [ 0 y x table nth set-nth ] if
        ] each
    ] each end n - end seq1 subseq ;

: pad-longest ( seq1 seq2 elt -- seq1 seq2 )
    [ 2dup max-length ] dip [ pad-tail ] 2curry bi@ ;

: change-nths ( ... indices seq quot: ( ... elt -- ... elt' ) -- ... )
    [ change-nth ] 2curry each ; inline

: push-if-index ( ..a elt i quot: ( ..a elt i -- ..b ? ) accum -- ..b )
    [ 2keep drop ] dip rot [ push ] [ 2drop ] if ; inline

: index-selector-for ( quot exemplar -- selector accum )
    [ length ] keep new-resizable [ [ push-if-index ] 2curry ] keep ; inline

: filter-index-as ( ... seq quot: ( ... elt i -- ... ? ) exemplar -- ... seq' )
    dup [ index-selector-for [ each-index ] dip ] curry dip like ; inline

: filter-index ( ... seq quot: ( ... elt i -- ... ? ) -- ... seq' )
    over filter-index-as ; inline

: even-indices ( seq -- seq' ) [ nip even? ] filter-index ;

: odd-indices ( seq -- seq' ) [ nip odd? ] filter-index ;

: compact ( seq quot elt -- seq' )
    [ split-when harvest ] dip join ; inline

: collapse ( seq quot elt -- seq' )
    [ split-when ] dip
    [ [ harvest ] dip join ]
    [ [ first empty? ] dip [ prepend ] curry when ]
    [ [ last empty? ] dip [ append ] curry when ]
    2tri ; inline

:: slice-when ( seq quot: ( elt -- ? ) -- seq' )
    seq length :> len
    0 [ len dupd < ] [
        dup seq quot find-from drop
        [ 2dup = [ 1 + ] when ] [ len ] if*
        [ seq <slice> ] keep len or swap
    ] produce nip ; inline
