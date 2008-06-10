! Copyright (C) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: lcs html.elements kernel qualified ;
FROM: accessors => item>> ;
FROM: io => write ;
FROM: sequences => each empty? ;
FROM: xml.entities => escape-string ;
IN: lcs.diff2html

GENERIC: diff-line ( obj -- )

: write-item ( item -- )
    item>> dup empty? [ drop "&nbsp;" ] [ escape-string ] if write ;

M: retain diff-line
    <tr>
        dup [
            <td "retain" =class td>
                write-item
            </td>
        ] bi@
    </tr> ;

M: insert diff-line
    <tr>
        <td> </td>
        <td "insert" =class td>
            write-item
        </td>
    </tr> ;

M: delete diff-line
    <tr>
        <td "delete" =class td>
            write-item
        </td>
        <td> </td>
    </tr> ;

: htmlize-diff ( diff -- )
    <table "100%" =width "comparison" =class table>
        <tr> <th> "Old" write </th> <th> "New" write </th> </tr>
        [ diff-line ] each
    </table> ;
