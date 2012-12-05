! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces accessors xml.tokenize xml.data assocs
xml.errors xml.char-classes combinators.short-circuit splitting
fry xml.state sequences combinators ascii math make ;
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
    dup space>> dup ns-stack get assoc-stack
    [ nip ] [ nonexist-ns ] if* >>url drop ;

: push-ns ( hash -- )
    ns-stack get push ;

: pop-ns ( -- )
    ns-stack get pop* ;

: init-ns-stack ( -- )
    V{ H{
        { "xml" "http://www.w3.org/XML/1998/namespace" }
        { "xmlns" "http://www.w3.org/2000/xmlns" }
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

: maybe-name ( space main -- name/f )
    2dup {
        [ drop valid-name? ]
        [ nip valid-name? ]
    } 2&& [ f <name> ] [ 2drop f ] if ;

: prefixed-name ( str -- name/f )
    CHAR: : over index [
        CHAR: : 2over 1 + swap index-from
        [ 2drop f ]
        [ [ head ] [ 1 + tail ] 2bi maybe-name ]
        if
    ] [ drop f ] if* ;

: interpret-name ( str -- name )
    dup prefixed-name [ ] [
        dup valid-name?
        [ <simple-name> ] [ bad-name ] if
    ] ?if ;

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
