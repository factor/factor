! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces accessors xml.tokenize xml.data assocs
xml.errors xml.char-classes combinators.short-circuit splitting
fry xml.state sequences ;
IN: xml.name

! XML namespace processing: ns = namespace

! A stack of hashtables
SYMBOL: ns-stack

: attrs>ns ( attrs-alist -- hash )
    ! this should check to make sure URIs are valid
    [
        [
            swap dup space>> "xmlns" =
            [ main>> set ]
            [
                T{ name f "" "xmlns" f } names-match?
                [ "" set ] [ drop ] if
            ] if
        ] assoc-each
    ] { } make-assoc f like ;

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
        version=1.0? swap {
            [ first name-start? ]
            [ rest-slice [ name-char? ] with all? ]
        } 2&&
    ] if-empty ;

: prefixed-name ( str -- name/f )
    ":" split dup length 2 = [
        [ [ valid-name? ] all? ]
        [ first2 f <name> ] bi and
    ] [ drop f ] if ;

: interpret-name ( str -- name )
    dup prefixed-name [ ] [
        dup valid-name?
        [ <simple-name> ] [ bad-name ] if
    ] ?if ;

: take-name ( -- string )
    version=1.0? '[ _ get-char name-char? not ] take-until ;

: parse-name ( -- name )
    take-name interpret-name ;

: parse-name-starting ( string -- name )
    take-name append interpret-name ;

