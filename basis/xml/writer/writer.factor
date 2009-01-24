! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables kernel math namespaces sequences strings
assocs combinators io io.streams.string accessors
xml.data wrap xml.entities unicode.categories fry ;
IN: xml.writer

SYMBOL: xml-pprint?
SYMBOL: sensitive-tags
SYMBOL: indentation
SYMBOL: indenter
"  " indenter set-global

<PRIVATE

: sensitive? ( tag -- ? )
    sensitive-tags get swap '[ _ names-match? ] contains? ;

: indent-string ( -- string )
    xml-pprint? get
    [ indentation get indenter get <repetition> concat ]
    [ "" ] if ;

: ?indent ( -- )
    xml-pprint? get [ nl indent-string write ] when ;

: indent ( -- )
    xml-pprint? get [ 1 indentation +@ ] when ;

: unindent ( -- )
    xml-pprint? get [ -1 indentation +@ ] when ;

: trim-whitespace ( string -- no-whitespace )
    [ blank? ] trim ;

: ?filter-children ( children -- no-whitespace )
    xml-pprint? get [
        [ dup string? [ trim-whitespace ] when ] map
        [ [ empty? ] [ string? ] bi and not ] filter
    ] when ;

PRIVATE>

: name>string ( name -- string )
    [ main>> ] [ space>> ] bi [ ":" rot 3append ] unless-empty ;

: print-name ( name -- )
    name>string write ;

<PRIVATE

: print-attrs ( assoc -- )
    [
        " " write
        swap print-name
        "=\"" write
        escape-quoted-string write
        "\"" write
    ] assoc-each ;

PRIVATE>

GENERIC: write-xml-chunk ( object -- )

<PRIVATE

M: string write-xml-chunk
    escape-string xml-pprint? get [
        dup [ blank? ] all?
        [ drop "" ]
        [ nl 80 indent-string indented-break ] if
    ] when write ;

: write-tag ( tag -- )
    ?indent CHAR: < write1
    dup print-name attrs>> print-attrs ;

: write-start-tag ( tag -- )
    write-tag ">" write ;

M: contained-tag write-xml-chunk
    write-tag "/>" write ;

: write-children ( tag -- )
    indent children>> ?filter-children
    [ write-xml-chunk ] each unindent ;

: write-end-tag ( tag -- )
    ?indent "</" write print-name CHAR: > write1 ;

M: open-tag write-xml-chunk
    xml-pprint? get [
        {
            [ sensitive? not xml-pprint? get and xml-pprint? set ]
            [ write-start-tag ]
            [ write-children ]
            [ write-end-tag ]
        } cleave
    ] dip xml-pprint? set ;

M: comment write-xml-chunk
    "<!--" write text>> write "-->" write ;

M: element-decl write-xml-chunk
    "<!ELEMENT " write
    [ name>> write " " write ]
    [ content-spec>> write ">" write ]
    bi ;

M: attlist-decl write-xml-chunk
    "<!ATTLIST " write
    [ name>> write " " write ]
    [ att-defs>> write ">" write ]
    bi ;

M: notation-decl write-xml-chunk
    "<!NOTATION " write
    [ name>> write " " write ]
    [ id>> write ">" write ]
    bi ;

M: entity-decl write-xml-chunk
    "<!ENTITY " write
    [ pe?>> [ " % " write ] when ]
    [ name>> write " \"" write ] [
        def>> f xml-pprint?
        [ write-xml-chunk ] with-variable
        "\">" write
    ] tri ;

M: system-id write-xml-chunk
    "SYSTEM '" write system-literal>> write "'" write ;

M: public-id write-xml-chunk
    "PUBLIC '" write
    [ pubid-literal>> write "' '" write ]
    [ system-literal>> write "'" write ] bi ;

: write-internal-subset ( seq -- )
    [
        "[" write indent
        [ ?indent write-xml-chunk ] each
        unindent ?indent "]" write
    ] when* ;

M: doctype-decl write-xml-chunk
    ?indent "<!DOCTYPE " write
    [ name>> write " " write ]
    [ external-id>> [ write-xml-chunk " " write ] when* ]
    [ internal-subset>> write-internal-subset ">" write ] tri ;

M: directive write-xml-chunk
    "<!" write text>> write CHAR: > write1 nl ;

M: instruction write-xml-chunk
    "<?" write text>> write "?>" write ;

M: sequence write-xml-chunk
    [ write-xml-chunk ] each ;

PRIVATE>

: write-prolog ( xml -- )
    "<?xml version=\"" write dup version>> write
    "\" encoding=\"" write dup encoding>> write
    standalone>> [ "\" standalone=\"yes" write ] when
    "\"?>" write ;

: write-xml ( xml -- )
    {
        [ prolog>> write-prolog ]
        [ before>> write-xml-chunk ]
        [ body>> write-xml-chunk ]
        [ after>> write-xml-chunk ]
    } cleave ;

M: xml write-xml-chunk
    body>> write-xml-chunk ;

: xml>string ( xml -- string )
    [ write-xml ] with-string-writer ;

: xml-chunk>string ( object -- string )
    [ write-xml-chunk ] with-string-writer ;

: pprint-xml-but ( xml sensitive-tags -- )
    [
        [ assure-name ] map sensitive-tags set
        0 indentation set
        xml-pprint? on
        write-xml
    ] with-scope ;

: pprint-xml ( xml -- )
    f pprint-xml-but ;

: pprint-xml>string-but ( xml sensitive-tags -- string )
    [ pprint-xml-but ] with-string-writer ;

: pprint-xml>string ( xml -- string )
    f pprint-xml>string-but ;
