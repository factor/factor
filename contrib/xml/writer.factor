! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml
USING: hashtables kernel math namespaces sequences strings generic ;

GENERIC: (xml>string) ( object -- )

: print-name ( name -- )
    dup name-space [ % CHAR: : , ] when*
    name-tag % ;

: print-props ( hash -- )
    [
        " " % swap print-name "=\"" % [ (xml>string) ] each "\"" %
    ] hash-each ;

: chars>entities ( str -- str )
    #! Convert <, >, &, ' and " to HTML entities.
    [
        [ dup entities hash [ % ] [ , ] ?if ] each
    ] "" make ;

M: string (xml>string) chars>entities % ;

M: contained-tag (xml>string)
    CHAR: < ,
    dup tag-name print-name
    tag-props print-props
    "/>" % ;

M: tag (xml>string)
    CHAR: < ,
    dup tag-name print-name
    dup tag-props print-props
    CHAR: > ,
    dup tag-children [ (xml>string) ] each
    "</" % tag-name print-name CHAR: > , ;

M: comment (xml>string)
    "<!--" % comment-text % "-->" % ;

M: object (xml>string)
    [ (xml>string) ] each ;

M: directive (xml>string)
    "<!" % directive-text % CHAR: > , ;

M: instruction (xml>string)
    "<?" % instruction-text % "?>" % ;

M: entity (xml>string)
    CHAR: & , entity-name % CHAR: ; , ;

: xml-preamble ( xml -- )
    "<?xml version=\"" % dup prolog-version %
    "\" encoding=\"" % dup prolog-encoding %
    "\" standalone=\"" % prolog-standalone "yes" "no" ? %
    "\"?>" % ;

: xml>string ( xml-doc -- string )
    [ 
        dup xml-doc-prolog xml-preamble
        dup xml-doc-before (xml>string)
        dup delegate (xml>string)
        xml-doc-after (xml>string) ] "" make ;

: xml-reprint ( string -- string )
    string>xml xml>string ;

