USING: combinators kernel namespaces quotations regexp sequences
splitting xml.data xml.traversal ;
IN: xmode.utilities

: implies ( x y -- z ) [ not ] dip or ; inline

: tag-init-form ( spec -- quot )
    {
        { [ dup quotation? ] [ [ object get tag get ] prepose ] }
        { [ dup length 2 = ] [
            first2 '[
                tag get children>string
                _ [ execute ] when* object get _ execute
            ]
        ] }
        { [ dup length 3 = ] [
            first3 '[
                tag get _ attr
                _ [ execute ] when* object get _ execute
            ]
        ] }
    } cond ;

: with-tag-initializer ( tag obj quot -- )
    [ object set tag set ] prepose with-scope ; inline

MACRO: (init-from-tag) ( specs -- quot )
    [ tag-init-form ] map [ ] concat-as
    [ with-tag-initializer ] curry ;

: init-from-tag ( tag tuple specs -- tuple )
    over [ (init-from-tag) ] dip ; inline

: <?insensitive-regexp> ( string ? -- regexp )
    ! handle Java style case-insensitive flags
    "(?i)" pick subseq-start [ drop "(?i)" "" replace t ] when
    "i" "" ? <optioned-regexp> ;
