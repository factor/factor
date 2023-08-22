! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators io io.streams.string kernel
namespaces sequences strings unicode wrap.strings xml.data
xml.entities ;
IN: xml.writer

SYMBOL: sensitive-tags
SYMBOL: indenter
"  " indenter set-global

<PRIVATE

SYMBOL: xml-pprint?
SYMBOL: indentation

: sensitive? ( tag -- ? )
    sensitive-tags get swap '[ _ names-match? ] any? ;

: indent-string ( -- string )
    xml-pprint? get
    [ indentation get indenter get <repetition> "" concat-as ]
    [ "" ] if ;

: ?indent ( -- )
    xml-pprint? get [ nl indent-string write ] when ;

: indent ( -- )
    xml-pprint? get [ 1 indentation +@ ] when ;

: unindent ( -- )
    xml-pprint? get [ -1 indentation +@ ] when ;

: ?filter-children ( children -- no-whitespace )
    xml-pprint? get [
        [ dup string? [ [ blank? ] trim ] when ] map
        "" swap remove
    ] when ;

PRIVATE>

: name>string ( name -- string )
    [ main>> ] [ space>> ] bi [ ":" rot 3append ] unless-empty ;

: print-name ( name -- )
    name>string write ;

<PRIVATE

: write-quoted ( string -- )
    CHAR: \" write1 write CHAR: \" write1 ;

: print-attrs ( assoc -- )
    [
        [ bl print-name "=" write ]
        [ escape-quoted-string write-quoted ] bi*
    ] assoc-each ;

PRIVATE>

GENERIC: write-xml ( xml -- )

<PRIVATE

M: string write-xml
    escape-string xml-pprint? get [
        dup [ blank? ] all?
        [ drop "" ]
        [ nl 80 indent-string wrap-indented-string ] if
    ] when write ;

: write-tag ( tag -- )
    ?indent CHAR: < write1
    dup print-name attrs>> print-attrs ;

: write-start-tag ( tag -- )
    write-tag ">" write ;

M: contained-tag write-xml
    write-tag "/>" write ;

: write-children ( tag -- )
    indent children>> ?filter-children
    [ write-xml ] each unindent ;

: write-end-tag ( tag -- )
    ?indent "</" write print-name CHAR: > write1 ;

M: open-tag write-xml
    xml-pprint? get [
        {
            [ write-start-tag ]
            [ sensitive? not xml-pprint? get and xml-pprint? set ]
            [ write-children ]
            [ write-end-tag ]
        } cleave
    ] dip xml-pprint? set ;

M: unescaped write-xml
    string>> write ;

M: comment write-xml
    "<!--" write text>> write "-->" write ;

M: cdata write-xml
    "<![CDATA[" write text>> write "]]>" write ;

: write-decl ( decl name quot: ( decl -- slot ) -- )
    "<!" write swap write bl
    [ name>> write bl ]
    swap '[ @ write ">" write ] bi ; inline

M: element-decl write-xml
    "ELEMENT" [ content-spec>> ] write-decl ;

M: attlist-decl write-xml
    "ATTLIST" [ att-defs>> ] write-decl ;

M: notation-decl write-xml
    "NOTATION" [ id>> ] write-decl ;

M: entity-decl write-xml
    "<!ENTITY " write
    [ pe?>> [ " % " write ] when ]
    [ name>> write " \"" write ] [
        def>> f xml-pprint?
        [ write-xml ] with-variable
        "\">" write
    ] tri ;

M: system-id write-xml
    "SYSTEM" write bl system-literal>> write-quoted ;

M: public-id write-xml
    "PUBLIC" write bl
    [ pubid-literal>> write-quoted bl ]
    [ system-literal>> write-quoted ] bi ;

: write-internal-subset ( dtd -- )
    [
        "[" write indent
        directives>> [ ?indent write-xml ] each
        unindent ?indent "]" write
    ] when* ;

M: doctype-decl write-xml
    ?indent "<!DOCTYPE " write
    [ name>> write ]
    [ external-id>> [ bl write-xml ] when* ]
    [ internal-subset>> [ bl write-internal-subset ] when* ] tri
    ">" write ;

M: directive write-xml
    "<!" write text>> write CHAR: > write1 nl ;

M: instruction write-xml
    "<?" write text>> write "?>" write ;

M: sequence write-xml
    [ write-xml ] each ;

M: prolog write-xml
    "<?xml version=" write
    [ version>> write-quoted ]
    [ drop " encoding=\"UTF-8\"" write ]
    [ standalone>> [ " standalone=\"yes\"" write ] when ] tri
    "?>" write ;

M: xml write-xml
    {
        [ prolog>> write-xml ]
        [ before>> write-xml ]
        [ body>> write-xml ]
        [ after>> write-xml ]
    } cleave ;

PRIVATE>

: xml>string ( xml -- string )
    [ write-xml ] with-string-writer ;

: pprint-xml ( xml -- )
    [
        sensitive-tags [ [ assure-name ] map ] change
        0 indentation set
        xml-pprint? on
        write-xml
    ] with-scope ;

: pprint-xml>string ( xml -- string )
    [ pprint-xml ] with-string-writer ;
