! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables kernel math namespaces sequences strings
io io.streams.string xml.data assocs ;
IN: xml.writer

SYMBOL: xml-pprint?
SYMBOL: sensitive-tags
SYMBOL: indentation
SYMBOL: indenter
"  " indenter set-global

: sensitive? ( tag -- ? )
    sensitive-tags get swap [ names-match? ] curry contains? ;

: ?indent ( -- )
    xml-pprint? get [
        nl indentation get indenter get <repetition> [ write ] each
    ] when ;

: indent ( -- )
    xml-pprint? get [ 1 indentation +@ ] when ;

: unindent ( -- )
    xml-pprint? get [ -1 indentation +@ ] when ;

: trim-whitespace ( string -- no-whitespace )
    [ [ blank? not ] find drop 0 or ] keep
    [ [ blank? not ] find-last drop [ 1+ ] [ 0 ] if* ] keep
    subseq ;

: ?filter-children ( children -- no-whitespace )
    xml-pprint? get [
        [ dup string? [ trim-whitespace ] when ] map
        [ dup empty? swap string? and not ] subset
    ] when ;

: entities-out
    H{
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
    } ;

: quoted-entities-out
    H{
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;

: escape-string-by ( str table -- escaped )
    #! Convert <, >, &, ' and " to HTML entities.
    [ [ dupd at [ % ] [ , ] ?if ] curry each ] "" make ;

: escape-string ( str -- newstr )
    entities-out escape-string-by ;

: escape-quoted-string ( str -- newstr )
    quoted-entities-out escape-string-by ;

: print-name ( name -- )
    dup name-space f like
    [ write CHAR: : write1 ] when*
    name-tag write ;

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
    escape-string write ;

: write-tag ( tag -- )
    CHAR: < write1
    dup print-name tag-attrs print-attrs ;

M: contained-tag write-item
    write-tag "/>" write ;

: write-children ( tag -- )
    indent tag-children ?filter-children
    [ ?indent write-item ] each unindent ;

: write-end-tag ( tag -- )
    ?indent "</" write print-name CHAR: > write1 ;

M: open-tag write-item
    xml-pprint? [ [
        over sensitive? not and xml-pprint? set
        dup write-tag CHAR: > write1
        dup write-children write-end-tag
    ] keep ] change ;

M: comment write-item
    "<!--" write comment-text write "-->" write ;

M: directive write-item
    "<!" write directive-text write CHAR: > write1 ;

M: instruction write-item
    "<?" write instruction-text write "?>" write ;

: write-prolog ( xml -- )
    "<?xml version=\"" write dup prolog-version write
    "\" encoding=\"" write dup prolog-encoding write
    prolog-standalone [ "\" standalone=\"yes" write ] when
    "\"?>\n" write ;

: write-chunk ( seq -- )
    [ write-item ] each ;

: write-xml ( xml -- )
    dup xml-prolog write-prolog
    dup xml-before write-chunk
    dup write-item
    xml-after write-chunk ;

: print-xml ( xml -- )
    write-xml nl ;

: xml>string ( xml -- string )
    [ write-xml ] string-out ;

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
