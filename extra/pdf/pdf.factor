! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: io.files io.styles kernel pdf.layout sequences splitting ;

IN: pdf

: text-to-pdf ( str -- pdf )
    split-lines [
        H{ { font-name "monospace" } { font-size 10 } } <p>
    ] map pdf>string ;

: file-to-pdf ( path encoding -- )
    [ file-contents text-to-pdf ]
    [ [ ".pdf" append ] dip set-file-contents ] 2bi ;
