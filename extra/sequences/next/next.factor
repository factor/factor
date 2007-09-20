USING: kernel sequences sequences.private math ;
IN: sequences.next

<PRIVATE

: (map-next) ( i seq quot -- )
    ! this uses O(n) more bounds checks than is really necessary
    >r [ >r 1+ r> ?nth ] 2keep nth-unsafe r> call ; inline

PRIVATE>

: each-next ( seq quot -- )
    ! quot: next-elt elt --
    iterate-seq [ (map-next) ] 2curry each-integer ; inline

: map-next ( seq quot -- newseq )
    ! quot: next-elt elt -- newelt
    over dup length swap new >r
    iterate-seq [ (map-next) ] 2curry
    r> [ collect ] keep ; inline
