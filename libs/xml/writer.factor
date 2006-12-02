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

GENERIC: (xml>string) ( object -- )

M: str-elem (xml>string) ! string element
    write-str-elem ;

M: contained-tag (xml>string)
    CHAR: < write1
    dup print-name
    tag-props print-props
    "/>" write ;

M: tag (xml>string)
    CHAR: < write1
    dup print-name
    dup tag-props print-props
    CHAR: > write1
    dup tag-children [ (xml>string) ] each
    "</" write print-name CHAR: > write1 ;

M: comment (xml>string)
    "<!--" write comment-text write "-->" write ;

M: directive (xml>string)
    "<!" write directive-text write CHAR: > write1 ;

M: instruction (xml>string)
    "<?" write instruction-text write "?>" write ;

: xml-preamble ( xml -- )
    "<?xml version=\"" write dup prolog-version write
    "\" encoding=\"" write dup prolog-encoding write
    "\" standalone=\"" write
    prolog-standalone "yes" "no" ? write
    "\"?>" write ;

: write-xml ( xml-doc -- )
    dup xml-doc-prolog xml-preamble
    dup xml-doc-before [ (xml>string) ] each
    dup delegate (xml>string)
    xml-doc-after [ (xml>string) ] each ;

: print-xml ( xml-doc -- )
    write-xml terpri ;

: xml>string ( xml-doc -- string )
    [ write-xml ] string-out ;

: xml-reprint ( string -- string )
    string>xml xml>string ;

