! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
fry html.parser http.client io kernel locals math sequences
sets splitting unicode.case unicode.categories urls
urls.encoding ;
IN: html.parser.analyzer

: scrape-html ( url -- headers vector )
    http-get parse-html ;

: attribute ( tag string -- obj/f )
    swap attributes>> [ at ] [ drop f ] if* ;

: attribute* ( tag string -- obj ? )
    swap attributes>> [ at* ] [ drop f f ] if* ;

: attribute? ( tag string -- obj )
    swap attributes>> [ key? ] [ drop f ] if* ;

: find-all ( seq quot -- alist )
   [ <enum> >alist ] [ '[ second @ ] ] bi* filter ; inline

: loopn-index ( ... pred: ( ... n -- ... ? ) n -- ... )
    dup 0 > [
        [ swap call ] [ 1 - ] 2bi
        [ loopn-index ] 2curry when
    ] [
        2drop
    ] if ; inline recursive

: loopn ( ... pred: ( ... -- ... ? ) n -- ... )
    [ [ drop ] prepose ] dip loopn-index ; inline

:: find-nth ( n seq quot -- i/f elt/f )
    0 t [
        [ drop seq quot find-from ] dip 1 = [
            over [ [ 1 + ] dip ] when
        ] unless over >boolean
    ] n loopn-index ; inline

: find-first-name ( vector string -- i/f tag/f )
    >lower '[ name>> _ = ] find ; inline

: find-matching-close ( vector string -- i/f tag/f )
    >lower
    '[ [ name>> _ = ] [ closing?>> ] bi and ] find ; inline

: find-between* ( vector i/f tag/f -- vector )
    over integer? [
        [ tail-slice ] [ name>> ] bi*
        dupd find-matching-close drop [ 1 + ] [ 1 ] if*
        head
    ] [
        3drop V{ } clone
    ] if ; inline

: find-between ( vector i/f tag/f -- vector )
    find-between* dup length 3 >= [
        [ rest-slice but-last-slice ] keep like
    ] when ; inline

: find-between-first ( vector string -- vector' )
    dupd find-first-name find-between ; inline

: find-between-all ( vector quot -- seq )
    dupd
    '[ _ [ closing?>> not ] bi and ] find-all
    [ first2 find-between* ] with map ; inline

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

: find-by-id ( vector id -- vector' elt/f )
    '[ "id" attribute _ = ] find ;
    
: find-by-class ( vector id -- vector' elt/f )
    '[ "class" attribute _ = ] find ;

: find-by-name ( vector string -- vector elt/f )
    >lower '[ name>> _ = ] find ;

: find-by-id-between ( vector string -- vector' )
    dupd
    '[ "id" attribute _ = ] find find-between* ;
    
: find-by-class-between ( vector string -- vector' )
    dupd
    '[ "class" attribute _ = ] find find-between* ;
    
: find-by-class-id-between ( vector class id -- vector' )
    [
        '[
            [ "class" attribute _ = ]
            [ "id" attribute _ = ] bi and
        ] find
    ] [
        2drop find-between*
    ] 3bi ;

: find-by-attribute-key ( vector key -- vector' elt/? )
    >lower
    [ attributes>> at _ = ] filter sift ;

: find-by-attribute-key-value ( vector value key -- vector' )
    >lower
    [ attributes>> at over = ] with filter nip sift ;

: find-first-attribute-key-value ( vector value key -- i/f tag/f )
    >lower
    [ attributes>> at over = ] with find rot drop ;

: tag-link ( tag -- link/f ) "href" attribute ;

: find-links ( vector -- vector' )
    [ { [ name>> "a" = ] [ "href" attribute ] } 1&& ]
    find-between-all ;

: find-images ( vector -- vector' )
    [
        {
            [ name>> "img" = ]
            [ "src" attribute ]
        } 1&&
    ] find-all
    values [ "src" attribute ] map ;

: find-by-text ( seq quot -- tag )
    [ dup name>> text = ] prepose find drop ; inline

: find-opening-tags-by-name ( name seq -- seq )
    [ { [ name>> = ] [ closing?>> not ] } 1&& ] with find-all ;

: href-contains? ( str tag -- ? )
    "href" attribute* [ subseq? ] [ 2drop f ] if ;

: find-hrefs ( vector -- vector' )
    find-links
    [ [ { [ name>> "a" = ] [ "href" attribute? ] } 1&& ] filter ] map sift
    [ [ "href" attribute ] map ] map concat [ >url ] map ;

: find-frame-links ( vector -- vector' )
    [ name>> "frame" = ] find-between-all
    [ [ "src" attribute ] map sift ] map concat sift
    [ >url ] map ;

: find-all-links ( vector -- vector' )
    [ find-hrefs ] [ find-frame-links ] bi union ;

: find-forms ( vector -- vector' )
    "form" over find-opening-tags-by-name
    swap [ [ first2 ] dip find-between* ] curry map
    [ [ name>> { "form" "input" } member? ] filter ] map ;

: find-html-objects ( vector string -- vector' )
    dupd find-opening-tags-by-name
    [ first2 find-between* ] curry map ;

: form-action ( vector -- string )
    [ name>> "form" = ] find nip "action" attribute ;

: hidden-form-values ( vector -- strings )
    [ "type" attribute "hidden" = ] filter ;

: input. ( tag -- )
    dup name>> print
    attributes>>
    [ bl bl bl bl [ write "=" write ] [ write bl ] bi* nl ] assoc-each ;

: form. ( vector -- )
    [ closing?>> not ] filter
    [
        {
            { [ dup name>> "form" = ]
                [ "form action: " write "action" attribute print ] }
            { [ dup name>> "input" = ] [ input. ] }
            [ drop ]
        } cond
    ] each ;

: query>assoc* ( str -- hash )
    "?" split1 nip query>assoc ;
    
: html-class? ( tag string -- ? )
    swap "class" attribute = ;
    
: html-id? ( tag string -- ? )
    swap "id" attribute = ;

: opening-tag? ( tag -- ? )
    closing?>> not ;

TUPLE: link attributes clickable ;

: <link> ( vector -- link )
    [ first attributes>> ]
    [ [ name>> { text "img" } member? ] filter ] bi
    link boa ;

: link. ( vector -- )
    [ "href" attribute write nl ]
    [ clickable>> [ bl bl text>> print ] each nl ] bi ;
