USING: kernel sequences sequences.private math ;
IN: sequences.next

<PRIVATE

: iterate-seq ( seq quot -- i seq quot )
    [ [ length ] keep ] dip ; inline

: (map-next) ( i seq quot -- )
    ! this uses O(n) more bounds checks than is really necessary
    [ [ [ 1+ ] dip ?nth ] 2keep nth-unsafe ] dip call ; inline

PRIVATE>

: each-next ( seq quot: ( next-elt elt -- ) -- )
    iterate-seq [ (map-next) ] 2curry each-integer ; inline

: map-next ( seq quot: ( next-elt elt -- newelt ) -- newseq )
    over dup length swap new-sequence [
        iterate-seq [ (map-next) ] 2curry
    ] dip [ collect ] keep ; inline
