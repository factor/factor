! Copyright (C) 2009 Slava Pestov, Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays fry kernel math.order sequences sorting ;
IN: sorting.slots

: execute-comparator ( obj1 obj2 word -- <=>/f )
    execute( obj1 obj2 -- <=> ) dup +eq+ eq? [ drop f ] when ;

: execute-accessor ( obj1 obj2 word -- obj1' obj2' )
    '[ _ execute( tuple -- value ) ] bi@ ;

: compare-slots ( obj1 obj2 sort-specs -- <=> )
    #! sort-spec: { accessors comparator }
    [
        dup array? [
            unclip-last-slice
            [ [ execute-accessor ] each ] dip
        ] when execute-comparator
    ] with with map-find drop +eq+ or ;

: sort-by-with ( seq sort-specs quot -- seq' )
    swap '[ _ bi@ _ compare-slots ] sort ; inline

: sort-by ( seq sort-specs -- seq' ) [ ] sort-by-with ;

: sort-keys-by ( seq sort-seq -- seq' ) [ first ] sort-by-with ;

: sort-values-by ( seq sort-seq -- seq' ) [ second ] sort-by-with ;
