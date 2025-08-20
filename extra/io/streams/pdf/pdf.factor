! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays destructors io io.styles kernel
pdf.layout sequences splitting strings ;

IN: io.streams.pdf

<PRIVATE

! FIXME: what about "proper" tab support?

: string>texts ( string style -- seq )
    [ split-lines ] dip '[ _ <text> 1array ] map
    <br> 1array join ;

PRIVATE>


TUPLE: pdf-writer < disposable data ;

: new-pdf-writer ( class -- pdf-writer )
    new-disposable V{ } clone >>data ;

: <pdf-writer> ( -- pdf-writer )
    pdf-writer new-pdf-writer ;

: with-pdf-writer ( quot -- pdf )
    <pdf-writer> [ swap with-output-stream* ] keep data>> ; inline

TUPLE: pdf-sub-stream < pdf-writer parent ;

: new-pdf-sub-stream ( style stream class -- stream )
    new-pdf-writer
        swap >>parent
    swap <style-stream> ;

TUPLE: pdf-block-stream < pdf-sub-stream ;

M: pdf-block-stream dispose*
    [ data>> ] [ parent>> ] bi
    [ data>> push-all ] [ stream-nl ] bi ;


! Stream protocol

M: pdf-writer stream-flush drop ;

M: pdf-writer stream-write1
    [ 1string f <text> ] [ data>> ] bi* push ;

M: pdf-writer stream-write
    [ f string>texts ] [ data>> ] bi* push-all ;

M: pdf-writer stream-format
    [ string>texts ] [ data>> ] bi* push-all ;

M: pdf-writer stream-nl
    <br> swap data>> push ; ! FIXME: <br> needs style?

M: pdf-writer make-span-stream
    swap <style-stream> <ignore-close-stream> ;

M: pdf-writer make-block-stream
    pdf-block-stream new-pdf-sub-stream ;

M: pdf-writer make-cell-stream
    pdf-sub-stream new-pdf-sub-stream ;

! FIXME: real table cells
M: pdf-writer stream-write-table ! FIXME: needs style?
    nip swap [
        [ stream>> data>> <table-cell> ] map <table-row>
    ] map <table> swap data>> push ;

M: pdf-writer dispose* drop ;
