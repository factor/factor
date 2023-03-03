! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs combinators
combinators.short-circuit kernel make math namespaces sequences
xml.char-classes xml.data xml.errors xml.state xml.tokenize ;
IN: xml.name

! XML namespace processing: ns = namespace

! A stack of hashtables
SYMBOL: ns-stack

: attrs>ns ( attrs-alist -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            swap dup space>> "xmlns" =
            [ main>> ,, ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" ,, ] [ drop ] if
            ] if
        ] assoc-each
    ] { } make f like ;

: add-ns ( name -- )
    dup space>>
    [ ns-stack get assoc-stack ]
    [ nonexist-ns ] ?unless >>url drop ;

: push-ns ( hash -- )
    ns-stack get push ;

: pop-ns ( -- )
    ns-stack get pop* ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "https://www.w3.org/XML/1998/namespace" }
        { "xmlns" "https://www.w3.org/2000/xmlns" }
        { "" "" }
    } } clone
    ns-stack set ;

: tag-ns ( name attrs-alist -- name attrs )
    dup attrs>ns push-ns
    [ dup add-ns ] dip dup [ drop add-ns ] assoc-each <attrs> ;

: valid-name? ( str -- ? )
    [ f ] [
        version-1.0? swap {
            [ first name-start? ]
            [ rest-slice [ name-char? ] with all? ]
        } 2&&
    ] if-empty ;

<PRIVATE

: valid-name-start? ( str -- ? )
    [ f ] [ version-1.0? swap first name-start? ] if-empty ;

: maybe-name ( space main -- name/f )
    2dup {
        [ drop valid-name-start? ]
        [ nip valid-name-start? ]
    } 2&& [ f <name> ] [ 2drop f ] if ;

: prefixed-name ( str -- name/f )
    CHAR: : over index [
        CHAR: : 2over 1 + swap index-from
        [ 2drop f ]
        [ [ head ] [ 1 + tail ] 2bi maybe-name ]
        if
    ] [ drop f ] if* ;

: interpret-name ( str -- name )
    [ prefixed-name ] [ <simple-name> ] ?unless ;

PRIVATE>

: take-name ( -- string )
    version-1.0? '[ _ swap name-char? not ] take-until ;

: parse-name ( -- name )
    take-name interpret-name ;

: parse-name-starting ( string -- name )
    take-name append interpret-name ;

: take-system-id ( -- system-id )
    parse-quote <system-id> ;

: take-public-id ( -- public-id )
    parse-quote parse-quote <public-id> ;

: (take-external-id) ( token -- external-id )
    pass-blank {
        { "SYSTEM" [ take-system-id ] }
        { "PUBLIC" [ take-public-id ] }
        [ bad-external-id ]
    } case ;

: take-word ( -- string )
    [ blank? ] take-until ;

: take-external-id ( -- external-id )
    take-word (take-external-id) ;
