! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs kernel math.order quotations sequences
sorting ;
IN: sorting.specification

: execute-comparator ( obj1 obj2 word -- <=>/f )
    execute( obj1 obj2 -- <=> ) dup +eq+ eq? [ drop f ] when ;

: call-accessor ( obj1 obj2 quot -- obj1' obj2' )
    '[ _ call( obj -- value ) ] bi@ ;

: execute-accessor ( obj1 obj2 word -- obj1' obj2' )
    '[ _ execute( tuple -- value ) ] bi@ ;

: compare-with-spec ( obj1 obj2 sort-spec -- <=> )
    ! sort-spec: { { accessor ... comparator } ... }
    [
        dup array? [
            unclip-last-slice
            [ [ dup quotation? [ call-accessor ] [ execute-accessor ] if ] each ] dip
        ] when execute-comparator
    ] 2with map-find drop +eq+ or ;

: sort-with-spec-by ( seq sort-spec quot: ( obj -- key ) -- sortedseq )
    swap '[ _ bi@ _ compare-with-spec ] sort-with ; inline

: sort-with-spec ( seq sort-spec -- seq' ) [ ] sort-with-spec-by ;

: sort-keys-with-spec ( assoc sort-spec -- alist )
    [ >alist ] dip [ first ] sort-with-spec-by ;

: sort-values-with-spec ( assoc sort-spec -- alist )
    [ >alist ] dip [ second ] sort-with-spec-by ;
