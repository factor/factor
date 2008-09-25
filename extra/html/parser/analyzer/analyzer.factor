USING: assocs html.parser kernel math sequences strings ascii
arrays generalizations shuffle unicode.case namespaces make
splitting http accessors io combinators http.client urls
fry sequences.lib ;
IN: html.parser.analyzer

TUPLE: link attributes clickable ;

: scrape-html ( url -- vector )
    http-get nip parse-html ;

: find-all ( seq quot -- alist )
   [ <enum> >alist ] [ '[ second @ ] ] bi* filter ; inline

: find-nth ( seq quot n -- i elt )
    [ <enum> >alist ] 2dip -rot
    '[ _ [ second @ ] find-from rot drop swap 1+ ]
    [ f 0 ] 2dip times drop first2 ; inline


: find-first-name ( str vector -- i/f tag/f )
    [ >lower ] dip [ name>> = ] with find ; inline

: find-matching-close ( str vector -- i/f tag/f )
    [ >lower ] dip
    [ [ name>> = ] [ closing?>> ] bi and ] with find ; inline

: find-between* ( i/f tag/f vector -- vector )
    pick integer? [
        rot tail-slice
        >r name>> r>
        [ find-matching-close drop dup [ 1+ ] when ] keep
        swap [ head ] [ first ] if*
    ] [
        3drop V{ } clone
    ] if ; inline
    
: find-between ( i/f tag/f vector -- vector )
    find-between* dup length 3 >= [
        [ rest-slice but-last-slice ] keep like
    ] when ; inline

: find-between-first ( string vector -- vector' )
    [ find-first-name ] keep find-between ; inline

: find-between-all ( vector quot -- seq )
    [ [ [ closing?>> not ] bi and ] curry find-all ] curry
    [ [ >r first2 r> find-between* ] curry map ] bi ; inline


: remove-blank-text ( vector -- vector' )
    [
        dup name>> text =
        [ text>> [ blank? ] all? not ] [ drop t ] if
    ] filter ;

: trim-text ( vector -- vector' )
    [
        dup name>> text =
        [ [ [ blank? ] trim ] change-text ] when
    ] map ;

: find-by-id ( id vector -- vector )
    [ attributes>> "id" swap at = ] with filter ;

: find-by-class ( id vector -- vector )
    [ attributes>> "class" swap at = ] with filter ;

: find-by-name ( str vector -- vector )
    [ >lower ] dip [ name>> = ] with filter ;

: find-by-attribute-key ( key vector -- vector )
    [ >lower ] dip
    [ attributes>> at ] with filter
    sift ;

: find-by-attribute-key-value ( value key vector -- vector )
    [ >lower ] dip
    [ attributes>> at over = ] with filter nip
    sift ;

: find-first-attribute-key-value ( value key vector -- i/f tag/f )
    [ >lower ] dip
    [ attributes>> at over = ] with find rot drop ;

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
    [ [ name>> = ] [ closing?>> not ] bi and ] with find-all ;

: href-contains? ( str tag -- ? )
    attributes>> "href" swap at* [ subseq? ] [ 2drop f ] if ;

: find-hrefs ( vector -- vector' )
    find-links
    [ [
        [ name>> "a" = ]
        [ attributes>> "href" swap key? ] bi and ] filter
    ] map sift [ [ attributes>> "href" swap at ] map ] map concat ;

: find-forms ( vector -- vector' )
    "form" over find-opening-tags-by-name
    swap [ >r first2 r> find-between* ] curry map
    [ [ name>> { "form" "input" } member? ] filter ] map ;

: find-html-objects ( string vector -- vector' )
    [ find-opening-tags-by-name ] keep
    [ [ first2 ] dip find-between* ] curry map ;

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
                [ "form action: " write attributes>> "action" swap at print ] }
            { [ dup name>> "input" = ] [ input. ] }
            [ drop ]
        } cond
    ] each ;

: query>assoc* ( str -- hash )
    "?" split1 nip query>assoc ;
