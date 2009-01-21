! Copyright (C) 2005, 2006 Daniel Ehrenberg
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

: name>string ( name -- string )
    [ main>> ] [ space>> ] bi [ ":" rot 3append ] unless-empty ;

: print-name ( name -- )
    name>string write ;

: print-attrs ( assoc -- )
    [
        " " write
        swap print-name
        "=\"" write
        escape-quoted-string write
        "\"" write
    ] assoc-each ;

GENERIC: write-xml-chunk ( object -- )

M: string write-xml-chunk
    escape-string dup empty? not xml-pprint? get and
    [ nl 80 indent-string indented-break ] when write ;

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

M: entity-decl write-xml-chunk
    "<!ENTITY " write
    [ name>> write " " write ]
    [ def>> write-xml-chunk ">" write ]
    bi ;

M: system-id write-xml-chunk
    "SYSTEM '" write system-literal>> write "'" write ;

M: public-id write-xml-chunk
    "PUBLIC '" write
    [ pubid-literal>> write "' '" write ]
    [ system-literal>> write "'" write ] bi ;

M: doctype-decl write-xml-chunk
    "<!DOCTYPE " write
    [ name>> write " " write ]
    [ external-id>> [ write-xml-chunk " " write ] when* ]
    [
        internal-subset>>
        [ "[" write [ write-xml-chunk ] each "]" write ] when* ">" write
    ] tri ;

M: directive write-xml-chunk
    "<!" write text>> write CHAR: > write1 ;

M: instruction write-xml-chunk
    "<?" write text>> write "?>" write ;

M: sequence write-xml-chunk
    [ write-xml-chunk ] each ;

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

: print-xml ( xml -- )
    write-xml nl ;

: xml>string ( xml -- string )
    [ write-xml ] with-string-writer ;

: xml-chunk>string ( object -- string )
    [ write-xml-chunk ] with-string-writer ;

: with-xml-pprint ( sensitive-tags quot -- )
    [
        swap [ assure-name ] map sensitive-tags set
        0 indentation set
        xml-pprint? on
        call
    ] with-scope ; inline

: pprint-xml-but ( xml sensitive-tags -- )
    [ print-xml ] with-xml-pprint ;

: pprint-xml ( xml -- )
    f pprint-xml-but ;

: pprint-xml>string-but ( xml sensitive-tags -- string )
    [ xml>string ] with-xml-pprint ;

: pprint-xml>string ( xml -- string )
    f pprint-xml>string-but ;
