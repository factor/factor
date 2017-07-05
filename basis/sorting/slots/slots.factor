! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs fry kernel math.order sequences sorting ;
IN: sorting.slots

: execute-comparator ( obj1 obj2 word -- <=>/f )
    execute( obj1 obj2 -- <=> ) dup +eq+ eq? [ drop f ] when ;

: execute-accessor ( obj1 obj2 word -- obj1' obj2' )
    '[ _ execute( tuple -- value ) ] bi@ ;

: compare-slots ( obj1 obj2 sort-specs -- <=> )
    ! sort-spec: { accessors comparator }
    [
        dup array? [
            unclip-last-slice
            [ [ execute-accessor ] each ] dip
        ] when execute-comparator
    ] 2with map-find drop +eq+ or ;

: sort-by-with ( seq sort-specs quot: ( obj -- key ) -- seq' )
    swap '[ _ bi@ _ compare-slots ] sort ; inline

: sort-by ( seq sort-specs -- seq' ) [ ] sort-by-with ;

: sort-keys-by ( alist sort-seq -- seq' )
    [ >alist ] dip [ first ] sort-by-with ;

: sort-values-by ( seq sort-seq -- seq' )
    [ >alist ] dip [ second ] sort-by-with ;
