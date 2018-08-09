! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make kernel assocs sequences fry
io.files io.encodings.binary xml.state ;
IN: xml.entities

CONSTANT: entities-out
    H{
        { ch'< "&lt;"   }
        { ch'> "&gt;"   }
        { ch'& "&amp;"  }
    }

CONSTANT: quoted-entities-out
    H{
        { ch'& "&amp;"  }
        { ch'\' "&apos;" }
        { ch'\" "&quot;" }
        { ch'< "&lt;"   }
    }

: escape-string-by ( str table -- escaped )
    ! Convert <, >, &, ' and " to HTML entities.
    [ '[ dup _ at [ % ] [ , ] ?if ] each ] "" make ;

: escape-string ( str -- newstr )
    entities-out escape-string-by ;

: escape-quoted-string ( str -- newstr )
    quoted-entities-out escape-string-by ;

CONSTANT: entities
    H{
        { "lt"    ch'<  }
        { "gt"    ch'>  }
        { "amp"   ch'&  }
        { "apos"  ch'\'  }
        { "quot"  ch'\"  }
    }

: with-entities ( entities quot -- )
    [ extra-entities ] dip with-variable ; inline
