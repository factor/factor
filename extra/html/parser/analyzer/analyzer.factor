! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs assocs.extras combinators
combinators.short-circuit html.parser http.client io kernel math
math.statistics sequences sets splitting unicode urls
urls.encoding ;
IN: html.parser.analyzer

: scrape-html ( url -- response vector )
    http-get parse-html ;

: attribute ( tag string -- obj/f )
    swap attributes>> at ;

: attribute* ( tag string -- obj ? )
    swap attributes>> at* ;

: attribute? ( tag string -- ? )
    swap attributes>> key? ;

: find-all ( seq quot -- alist )
    [ <enumerated> >alist ] [ '[ second @ ] ] bi* filter ; inline

: loopn-index ( n quot -- )
    [ <iota> ] [ '[ @ not ] ] bi* find 2drop ; inline

: loopn ( n quot -- )
    [ drop ] prepose loopn-index ; inline

: html-class? ( tag string -- ? )
    swap "class" attribute [ blank? ] split-when member? ;

: html-id? ( tag string -- ? )
    swap "id" attribute = ;

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

: stack-find ( seq quot: ( elt -- 1/0/-1 ) -- i/f )
    map cum-sum 0 swap index ; inline

: tag-classifier ( string -- quot )
    >lower
    '[ dup name>> _ = [ closing?>> -1 1  ? ] [ drop 0 ] if ] ; inline

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
    '[ _ html-id? ] find ;

: find-by-class ( vector id -- vector' elt/f )
    '[ _ html-class? ] find ;

: find-by-name ( vector string -- vector elt/f )
    >lower '[ name>> _ = ] find ;

: find-by-id-between ( vector string -- vector' )
    '[ _ html-id? ] dupd find find-between* ;

: find-by-class-between ( vector string -- vector' )
    '[ _ html-class? ] dupd find find-between* ;

: find-by-class-id-between ( vector class id -- vector' )
    '[
        [ _ html-class? ] [ _ html-id? ] bi and
    ] dupd find find-between* ;

: find-by-attribute-key ( vector key -- vector' )
    >lower '[ _ attribute? ] filter sift ;

: find-by-attribute-key-value ( vector value key -- vector' )
    >lower swap '[ _ attribute _ = ] filter sift ;

: find-first-attribute-key-value ( vector value key -- i/f tag/f )
    >lower swap '[ _ attribute _ = ] find ;

: find-links ( vector -- vector' )
    [ { [ name>> "a" = ] [ "href" attribute ] } 1&& ]
    find-between-all ;

: find-images ( vector -- vector' )
    [ { [ name>> "img" = ] [ "src" attribute ] } 1&& ] filter sift
    [ "src" attribute ] map ;

: find-by-text ( seq quot -- tag )
    [ dup name>> text = ] prepose find drop ; inline

: find-opening-tags-by-name ( name seq -- seq )
    [ { [ name>> = ] [ closing?>> not ] } 1&& ] with find-all ;

: href-contains? ( str tag -- ? )
    "href" attribute* [ swap subseq-of? ] [ 2drop f ] if ;

: find-hrefs ( vector -- vector' )
    [ { [ name>> "a" = ] [ "href" attribute? ] } 1&& ] filter sift
    [ "href" attribute >url ] map ;

: find-frame-links ( vector -- vector' )
    [ { [ name>> "frame" = ] [ "src" attribute? ] } 1&& ] filter sift
    [ "src" attribute >url ] map ;

: find-script-links ( vector -- vector' )
    [ { [ name>> "script" = ] [ "src" attribute? ] } 1&& ] filter sift
    [ "src" attribute >url ] map ;

: find-all-links ( vector -- vector' )
    [ find-hrefs ] [ find-frame-links ] [ find-script-links ] tri union union ;

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
    [ name>> print ] [ attributes>> ] bi
    [ bl bl bl bl [ write "=" write ] [ write bl ] bi* nl ] assoc-each ;

: form. ( vector -- )
    [ closing?>> ] reject
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

: find-classes-named ( seq name -- seq' )
    dupd
    '[ attributes>> "class" of _ = ] find-all
    [ find-between ] kv-with { } assoc>map ;

: find-classes-named* ( seq name -- seq' )
    dupd
    '[ attributes>> "class" of _ = ] find-all
    [ find-between* ] kv-with { } assoc>map ;
