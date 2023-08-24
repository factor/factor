! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors assocs calendar colors combinators fonts
formatting hashtables io kernel make math math.parser sequences
splitting strings xml.entities ;

IN: pdf.values

<PRIVATE

: escape-string ( str -- str' )
    H{
        { 0x08    "\\b"  }
        { 0x0c    "\\f"  }
        { CHAR: \n   "\\n"  }
        { CHAR: \r   "\\r"  }
        { CHAR: \t   "\\t"  }
        { CHAR: \\   "\\\\" }
        { CHAR: (    "\\("  }
        { CHAR: )    "\\)"  }
    } escape-string-by ;

PRIVATE>

GENERIC: pdf-value ( obj -- str )

M: number pdf-value number>string ;

M: t pdf-value drop "true" ;

M: f pdf-value drop "false" ;

M: color pdf-value
    >rgba-components drop "%f %f %f" sprintf ;

M: font pdf-value
    [
        "<<" ,
        "/Type /Font" ,
        "/Subtype /Type1" ,
        {
            [
                name>> {
                    { "sans-serif" [ "/Helvetica" ] }
                    { "serif"      [ "/Times"     ] }
                    { "monospace"  [ "/Courier"   ] }
                    [ " is unsupported" append throw ]
                } case
            ]
            [ [ bold?>> ] [ italic?>> ] bi or [ "-" append ] when ]
            [ bold?>> [ "Bold" append ] when ]
            [ italic?>> [ "Italic" append ] when ]
            [
                name>> { "sans-serif" "monospace" } member?
                [ "Italic" "Oblique" replace ] when
            ]
        } cleave
        "/BaseFont " prepend ,
        ">>" ,
    ] { } make join-lines ;

M: timestamp pdf-value
    "%Y%m%d%H%M%S" strftime "D:" prepend ;

M: string pdf-value
    escape-string "(" ")" surround ;

M: sequence pdf-value
    [ "[" % [ pdf-value % " " % ] each "]" % ] "" make ;

M: hashtable pdf-value
    [
        "<<\n" %
        [ swap % " " % pdf-value % "\n" % ] assoc-each
        ">>" %
    ] "" make ;

: pdf-write ( obj -- )
    pdf-value write ;
