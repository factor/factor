USING: assocs html.parser kernel math sequences strings ascii
arrays shuffle unicode.case namespaces splitting http
sequences.lib accessors io combinators http.client urls ;
IN: html.parser.analyzer

TUPLE: link attributes clickable ;

: scrape-html ( url -- vector )
    http-get parse-html ;

: (find-relative)
    [ >r + dup r> ?nth* [ 2drop f f ] unless ] [ 2drop f ] if ; inline

: find-relative ( seq quot n -- i elt )
    >r over [ find drop ] dip r> swap pick
    (find-relative) ; inline

: (find-all) ( n seq quot -- )
    2dup >r >r find-from [
        dupd 2array , 1+ r> r> (find-all)
    ] [
        r> r> 3drop
    ] if* ; inline

: find-all ( seq quot -- alist )
    [ 0 -rot (find-all) ] { } make ; inline

: (find-nth) ( offset seq quot n count -- obj )
    >r >r [ find-from ] 2keep 4 npick [
        r> r> 1+ 2dup <= [
            4drop
        ] [
            >r >r >r >r drop 1+ r> r> r> r>
            (find-nth)
        ] if
    ] [
        2drop r> r> 2drop
    ] if ; inline

: find-nth ( seq quot n -- i elt )
    0 -roll 0 (find-nth) ; inline

: find-nth-relative ( seq quot n offest -- i elt )
    >r [ find-nth ] 3keep 2drop nip r> swap pick
    (find-relative) ; inline

: remove-blank-text ( vector -- vector' )
    [
        dup name>> text = [
            text>> [ blank? ] all? not
        ] [
            drop t
        ] if
    ] filter ;

: trim-text ( vector -- vector' )
    [
        dup name>> text = [
            [ text>> [ blank? ] trim ] keep
            [ set-tag-text ] keep
        ] when
    ] map ;

: find-by-id ( id vector -- vector )
    [ attributes>> "id" swap at = ] with filter ;

: find-by-class ( id vector -- vector )
    [ attributes>> "class" swap at = ] with filter ;

: find-by-name ( str vector -- vector )
    >r >lower r>
    [ name>> = ] with filter ;

: find-first-name ( str vector -- i/f tag/f )
    >r >lower r>
    [ name>> = ] with find ;

: find-matching-close ( str vector -- i/f tag/f )
    >r >lower r>
    [ [ name>> = ] keep closing?>> and ] with find ;

: find-by-attribute-key ( key vector -- vector )
    >r >lower r>
    [ attributes>> at ] with filter
    sift ;

: find-by-attribute-key-value ( value key vector -- vector )
    >r >lower r>
    [ attributes>> at over = ] with filter nip
    sift ;

: find-first-attribute-key-value ( value key vector -- i/f tag/f )
    >r >lower r>
    [ attributes>> at over = ] with find rot drop ;

: find-between* ( i/f tag/f vector -- vector )
    pick integer? [
        rot tail-slice
        >r name>> r>
        [ find-matching-close drop dup [ 1+ ] when ] keep
        swap [ head ] [ first ] if*
    ] [
        3drop V{ } clone
    ] if ;
    
: find-between ( i/f tag/f vector -- vector )
    find-between* dup length 3 >= [
        [ rest-slice but-last-slice ] keep like
    ] when ;

: find-between-first ( string vector -- vector' )
    [ find-first-name ] keep find-between ;

: find-between-all ( vector quot -- seq )
    [ [ [ closing?>> not ] bi and ] curry find-all ] curry
    [ [ >r first2 r> find-between* ] curry map ] bi ;

: tag-link ( tag -- link/f )
    attributes>> [ "href" swap at ] [ f ] if* ;

: find-links ( vector -- vector' )
    [ [ name>> "a" = ] [ attributes>> "href" swap at ] bi and ]
    find-between-all ;

: <link> ( vector -- link )
    [ first attributes>> ]
    [ [ name>> { text "img" } member? ] filter ] bi
    link boa ;

: link. ( vector -- )
    [ attributes>> "href" swap at write nl ]
    [ clickable>> [ bl bl text>> print ] each nl ] bi ;

: find-by-text ( seq quot -- tag )
    [ dup name>> text = ] prepose find drop ;

: find-opening-tags-by-name ( name seq -- seq )
    [ [ name>> = ] keep closing?>> not and ] with find-all ;

: href-contains? ( str tag -- ? )
    attributes>> "href" swap at* [ subseq? ] [ 2drop f ] if ;


: find-forms ( vector -- vector' )
    "form" over find-opening-tags-by-name
    swap [ >r first2 r> find-between* ] curry map
    [ [ name>> { "form" "input" } member? ] filter ] map ;

: find-html-objects ( string vector -- vector' )
    [ find-opening-tags-by-name ] keep
    [ >r first2 r> find-between* ] curry map ;

: form-action ( vector -- string )
    [ name>> "form" = ] find nip 
    attributes>> "action" swap at ;

: hidden-form-values ( vector -- strings )
    [ attributes>> "type" swap at "hidden" = ] filter ;

: input. ( tag -- )
    dup name>> print
    attributes>>
    [ bl bl bl bl [ write "=" write ] [ write bl ] bi* nl ] assoc-each ;

: form. ( vector -- )
    [ closing?>> not ] filter
    [
        {
            { [ dup name>> "form" = ]
                [ "form action: " write attributes>> "action" swap at print
            ] }
            { [ dup name>> "input" = ] [ input. ] }
            [ drop ]
        } cond
    ] each ;

: query>assoc* ( str -- hash )
    "?" split1 nip query>assoc ;
