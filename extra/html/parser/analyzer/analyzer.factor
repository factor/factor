! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs html.parser kernel math sequences strings ascii
arrays generalizations shuffle namespaces make
splitting http accessors io combinators http.client urls
urls.encoding fry prettyprint sets combinators.short-circuit ;
IN: html.parser.analyzer

TUPLE: link attributes clickable ;

: scrape-html ( url -- headers vector )
    http-get parse-html ;

: find-all ( seq quot -- alist )
   [ <enum> >alist ] [ '[ second @ ] ] bi* filter ; inline

: find-nth ( seq quot n -- i elt )
    [ <enum> >alist ] 2dip -rot
    '[ _ [ second @ ] find-from rot drop swap 1 + ]
    [ f 0 ] 2dip times drop first2 ; inline

: find-first-name ( vector string -- i/f tag/f )
    >lower '[ name>> _ = ] find ; inline

: find-matching-close ( vector string -- i/f tag/f )
    >lower
    '[ [ name>> _ = ] [ closing?>> ] bi and ] find ; inline

: find-between* ( vector i/f tag/f -- vector )
    over integer? [
        [ tail-slice ] [ name>> ] bi*
        dupd find-matching-close drop dup [ 1 + ] when
        [ head ] [ first ] if*
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
    '[ attributes>> "id" at _ = ] find ;
    
: find-by-class ( vector id -- vector' elt/f )
    '[ attributes>> "class" at _ = ] find ;

: find-by-name ( vector string -- vector elt/f )
    >lower '[ name>> _ = ] find ;

: find-by-id-between ( vector string -- vector' )
    dupd
    '[ attributes>> "id" swap at _ = ] find find-between* ;
    
: find-by-class-between ( vector string -- vector' )
    dupd
    '[ attributes>> "class" swap at _ = ] find find-between* ;
    
: find-by-class-id-between ( vector class id -- vector' )
    '[
        [ attributes>> "class" swap at _ = ]
        [ attributes>> "id" swap at _ = ] bi and
    ] dupd find find-between* ;

: find-by-attribute-key ( vector key -- vector' elt/? )
    >lower
    [ attributes>> at _ = ] filter sift ;

: find-by-attribute-key-value ( vector value key -- vector' )
    >lower
    [ attributes>> at over = ] with filter nip
    sift ;

: find-first-attribute-key-value ( vector value key -- i/f tag/f )
    >lower
    [ attributes>> at over = ] with find rot drop ;

: tag-link ( tag -- link/f )
    attributes>> [ "href" swap at ] [ f ] if* ;

: find-links ( vector -- vector' )
    [ [ name>> "a" = ] [ attributes>> "href" swap at ] bi and ]
    find-between-all ;

: find-images ( vector -- vector' )
    [
        {
            [ name>> "img" = ]
            [ attributes>> "src" swap at ]
        } 1&&
    ] find-all
    values [ attributes>> "src" swap at ] map ;

: <link> ( vector -- link )
    [ first attributes>> ]
    [ [ name>> { text "img" } member? ] filter ] bi
    link boa ;

: link. ( vector -- )
    [ attributes>> "href" swap at write nl ]
    [ clickable>> [ bl bl text>> print ] each nl ] bi ;

: find-by-text ( seq quot -- tag )
    [ dup name>> text = ] prepose find drop ; inline

: find-opening-tags-by-name ( name seq -- seq )
    [ [ name>> = ] [ closing?>> not ] bi and ] with find-all ;

: href-contains? ( str tag -- ? )
    attributes>> "href" swap at* [ subseq? ] [ 2drop f ] if ;

: find-hrefs ( vector -- vector' )
    find-links
    [ [
        [ name>> "a" = ]
        [ attributes>> "href" swap key? ] bi and ] filter
    ] map sift
    [ [ attributes>> "href" swap at ] map ] map concat
    [ >url ] map ;

: find-frame-links ( vector -- vector' )
    [ name>> "frame" = ] find-between-all
    [ [ attributes>> "src" swap at ] map sift ] map concat sift
    [ >url ] map ;

: find-all-links ( vector -- vector' )
    [ find-hrefs ] [ find-frame-links ] bi append prune ;

: find-forms ( vector -- vector' )
    "form" over find-opening-tags-by-name
    swap [ [ first2 ] dip find-between* ] curry map
    [ [ name>> { "form" "input" } member? ] filter ] map ;

: find-html-objects ( vector string -- vector' )
    dupd find-opening-tags-by-name
    [ first2 find-between* ] curry map ;

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
    
: html-class? ( tag string -- ? )
    swap attributes>> "class" swap at = ;
    
: html-id? ( tag string -- ? )
    swap attributes>> "id" swap at = ;

: opening-tag? ( tag -- ? )
    closing?>> not ;
