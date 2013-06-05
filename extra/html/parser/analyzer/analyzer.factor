! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators combinators.short-circuit
fry html.parser http.client io kernel locals math math.statistics
sequences sets splitting unicode.case unicode.categories urls
urls.encoding shuffle ;
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

: loopn-index ( n quot -- )
    [ iota ] [ '[ @ not ] ] bi* find 2drop ; inline

: loopn ( n quot -- )
    [ drop ] prepose loopn-index ; inline

ERROR: undefined-find-nth m n seq quot ;

: check-trivial-find ( m n seq quot -- m n seq quot )
    pick 0 = [ undefined-find-nth ] when ; inline

: find-nth-from ( m n seq quot -- i/f elt/f )
    check-trivial-find [ f ] 3dip '[
        drop _ _ find-from [ dup [ 1 + ] when ] dip over
    ] loopn [ dup [ 1 - ] when ] dip ; inline

: find-nth ( n seq quot -- i/f elt/f )
    [ 0 ] 3dip find-nth-from ; inline

: find-last-nth-from ( m n seq quot -- i/f elt/f )
    check-trivial-find [ f ] 3dip '[
        drop _ _ find-last-from [ dup [ 1 - ] when ] dip over
    ] loopn [ dup [ 1 + ] when ] dip ; inline

: find-last-nth ( n seq quot -- i/f elt/f )
    [ [ nip length 1 - ] [ ] 2bi ] dip find-last-nth-from ; inline

: find-first-name ( vector string -- i/f tag/f )
    >lower '[ name>> _ = ] find ; inline

! Takes a sequence and a quotation expected to return -1 if the
! element decrements the stack, 0 if it doesnt affect it and 1 if it
! increments it. Then finds the matching element where the stack is
! empty.
: stack-find ( seq quot -- i/f )
    map cum-sum [ 0 = ] find drop ; inline

! Produces a function which returns 1 if the input item is an opening
! tag element with the specified name, -1 if it is a closing tag of
! the same name and 0 otherwise.
: tag-classifier ( string -- quot )
    >lower
    '[ dup name>> _ = [ closing?>> [ -1 ] [ 1 ] if ] [ drop 0 ] if ] ; inline

: find-between* ( vector i/f tag/f -- vector )
    over integer? [
        [ tail-slice ] [ name>> ] bi*
        dupd tag-classifier stack-find [ 1 + ] [ 1 ] if*
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
    over find-opening-tags-by-name
    [ first2 find-between* ] with map ;

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
