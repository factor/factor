! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: hashtables kernel math namespaces sequences strings
    io generic ;

GENERIC: write-str-elem ( elem -- )

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [ [ dup entities hash [ % ] [ , ] ?if ] each ] "" make ;

M: string write-str-elem
    chars>entities write ;

M: entity write-str-elem
    CHAR: & write1 entity-name write CHAR: ; write1 ;

M: reference write-str-elem
    CHAR: % write1 reference-name write CHAR: ; write1 ;

UNION: str-elem string entity reference ;

: print-name ( name -- )
    dup name-space dup "" = [ drop ]
    [ write CHAR: : write1 ] if
    name-tag write ;

: print-props ( hash -- )
    [
        " " write swap print-name "=\"" write
        [ write-str-elem ] each "\"" write
    ] hash-each ;

GENERIC: write-item ( object -- )

M: str-elem write-item ! string element
    write-str-elem ;

M: contained-tag write-item
    CHAR: < write1
    dup print-name
    tag-props print-props
    "/>" write ;

M: open-tag write-item
    CHAR: < write1
    dup print-name
    dup tag-props print-props
    CHAR: > write1
    dup tag-children [ write-item ] each
    "</" write print-name CHAR: > write1 ;

M: comment write-item
    "<!--" write comment-text write "-->" write ;

M: directive write-item
    "<!" write directive-text write CHAR: > write1 ;

M: instruction write-item
    "<?" write instruction-text write "?>" write ;

: xml-preamble ( xml -- )
    "<?xml version=\"" write dup prolog-version write
    "\" encoding=\"" write dup prolog-encoding write
    "\" standalone=\"" write
    prolog-standalone "yes" "no" ? write
    "\"?>" write ;

: write-chunk ( seq -- )
    [ write-item ] each ;

: write-xml ( xml-doc -- )
    dup xml-doc-prolog xml-preamble
    dup xml-doc-before write-chunk
    dup delegate write-item
    xml-doc-after write-chunk ;

: print-xml ( xml-doc -- )
    write-xml terpri ;

: xml>string ( xml-doc -- string )
    [ write-xml ] string-out ;

: xml-reprint ( string -- )
    string>xml print-xml ;

