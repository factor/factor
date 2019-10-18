! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: hashtables kernel math namespaces sequences strings
    io generic xml-data errors assocs ;
IN: xml-writer

: write-entities
    H{
        { CHAR: < "&lt;"   }
        { CHAR: > "&gt;"   }
        { CHAR: & "&amp;"  }
        { CHAR: ' "&apos;" }
        { CHAR: " "&quot;" }
    } ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [ [ dup write-entities at [ % ] [ , ] ?if ] each ] "" make ;

: print-name ( name -- )
    dup name-space dup "" = [ drop ]
    [ write CHAR: : write1 ] if
    name-tag write ;

: print-attrs ( hash -- )
    [
        first2 " " write
        swap print-name
        "=\"" write
        chars>entities write
        "\"" write
    ] each ;

GENERIC: write-item ( object -- )

M: string write-item
    chars>entities write ;

M: contained-tag write-item
    CHAR: < write1
    dup print-name
    tag-attrs print-attrs
    "/>" write ;

M: open-tag write-item
    CHAR: < write1
    dup print-name
    dup tag-attrs print-attrs
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

: write-xml ( xml -- )
    dup xml-prolog xml-preamble
    dup xml-before write-chunk
    dup write-item
    xml-after write-chunk ;

: print-xml ( xml -- )
    write-xml nl ;

: xml>string ( xml -- string )
    [ write-xml ] string-out ;

