! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: lcs xml.syntax xml.writer kernel strings ;
FROM: accessors => item>> ;
FROM: io => write ;
FROM: sequences => each if-empty when-empty map ;
IN: lcs.diff2html

GENERIC: diff-line ( obj -- xml )

: item-string ( item -- string )
    item>> [ CHAR: no-break-space 1string ] when-empty ;

M: retain diff-line
    item-string
    [XML <td class="retain"><-></td> XML]
    dup [XML <tr><-><-></tr> XML] ;

M: insert diff-line
    item-string [XML
        <tr>
            <td> </td>
            <td class="insert"><-></td>
        </tr>
    XML] ;

M: delete diff-line
    item-string [XML
        <tr>
            <td class="delete"><-></td>
            <td> </td>
        </tr>
    XML] ;

: htmlize-diff ( diff -- xml )
    [ diff-line ] map
    [XML
        <table width="100%" class="comparison">
            <tr><th>Old</th><th>New</th></tr>
            <->
        </table>
    XML] ;
