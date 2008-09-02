! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables kernel math namespaces sequences strings
assocs combinators io io.streams.string accessors
xml.data wrap xml.entities unicode.categories ;
IN: xml.writer

SYMBOL: xml-pprint?
SYMBOL: sensitive-tags
SYMBOL: indentation
SYMBOL: indenter
"  " indenter set-global

: sensitive? ( tag -- ? )
    sensitive-tags get swap [ names-match? ] curry contains? ;

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
        [ dup empty? swap string? and not ] filter
    ] when ;

: print-name ( name -- )
    dup space>> f like
    [ write CHAR: : write1 ] when*
    main>> write ;

: print-attrs ( assoc -- )
    [
        " " write
        swap print-name
        "=\"" write
        escape-quoted-string write
        "\"" write
    ] assoc-each ;

GENERIC: write-item ( object -- )

M: string write-item
    escape-string dup empty? not xml-pprint? get and
    [ nl 80 indent-string indented-break ] when write ;

: write-tag ( tag -- )
    ?indent CHAR: < write1
    dup print-name attrs>> print-attrs ;

: write-start-tag ( tag -- )
    write-tag ">" write ;

M: contained-tag write-item
    write-tag "/>" write ;

: write-children ( tag -- )
    indent children>> ?filter-children
    [ write-item ] each unindent ;

: write-end-tag ( tag -- )
    ?indent "</" write print-name CHAR: > write1 ;

M: open-tag write-item
    xml-pprint? get >r
    {
        [ sensitive? not xml-pprint? get and xml-pprint? set ]
        [ write-start-tag ]
        [ write-children ]
        [ write-end-tag ]
    } cleave
    r> xml-pprint? set ;

M: comment write-item
    "<!--" write text>> write "-->" write ;

M: directive write-item
    "<!" write text>> write CHAR: > write1 ;

M: instruction write-item
    "<?" write text>> write "?>" write ;

: write-prolog ( xml -- )
    "<?xml version=\"" write dup version>> write
    "\" encoding=\"" write dup encoding>> write
    standalone>> [ "\" standalone=\"yes" write ] when
    "\"?>" write ;

: write-chunk ( seq -- )
    [ write-item ] each ;

: write-xml ( xml -- )
    {
        [ prolog>> write-prolog ]
        [ before>> write-chunk ]
        [ body>> write-item ]
        [ after>> write-chunk ]
    } cleave ;

M: xml write-item
    body>> write-item ;

: print-xml ( xml -- )
    write-xml nl ;

: xml>string ( xml -- string )
    [ write-xml ] with-string-writer ;

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
