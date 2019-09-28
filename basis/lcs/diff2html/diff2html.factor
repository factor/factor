! Copyright (C) 2008, 2010 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel lcs sequences strings xml.syntax
xml.writer ;
IN: lcs.diff2html

GENERIC: diff-line ( obj -- xml )

: item-string ( item -- string )
    item>> [ char: no-break-space 1string ] when-empty ;

M: retain diff-line
    item-string
    XML-CHUNK[[ <td class="retain"><-></td> ]]
    dup XML-CHUNK[[ <tr><-><-></tr> ]] ;

M: insert diff-line
    item-string XML-CHUNK[[
        <tr>
            <td> </td>
            <td class="insert"><-></td>
        </tr>
    ]] ;

M: delete diff-line
    item-string XML-CHUNK[[
        <tr>
            <td class="delete"><-></td>
            <td> </td>
        </tr>
    ]] ;

: htmlize-diff ( diff -- xml )
    [ diff-line ] map
    XML-CHUNK[[
        <table width="100%" class="comparison">
            <tr><th>Old</th><th>New</th></tr>
            <->
        </table>
    ]] ;
