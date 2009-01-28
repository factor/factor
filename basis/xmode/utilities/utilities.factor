USING: accessors sequences assocs kernel quotations namespaces
xml.data xml.utilities combinators macros parser lexer words fry ;
IN: xmode.utilities

: implies ( x y -- z ) [ not ] dip or ; inline

: child-tags ( tag -- seq ) children>> [ tag? ] filter ;

: map-find ( seq quot -- result elt )
    [ f ] 2dip
    '[ nip @ dup ] find
    [ [ drop f ] unless ] dip ; inline

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
                _ tag get at
                _ [ execute ] when* object get _ execute
            ]
        ] }
    } cond ;

: with-tag-initializer ( tag obj quot -- )
    [ object set tag set ] prepose with-scope ; inline

MACRO: (init-from-tag) ( specs -- )
    [ tag-init-form ] map concat [ ] like
    [ with-tag-initializer ] curry ;

: init-from-tag ( tag tuple specs -- tuple )
    over [ (init-from-tag) ] dip ; inline

SYMBOL: tag-handlers
SYMBOL: tag-handler-word

: <TAGS:
    CREATE tag-handler-word set
    H{ } clone tag-handlers set ; parsing

: (TAG:) ( name quot -- ) swap tag-handlers get set-at ;

: TAG:
    scan parse-definition
    (TAG:) ; parsing

: TAGS>
    tag-handler-word get
    tag-handlers get >alist [ [ dup main>> ] dip case ] curry
    define ; parsing
