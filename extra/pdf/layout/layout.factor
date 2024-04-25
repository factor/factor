! Copyright (C) 2011-2012 John Benediktsson
! See https://factorcode.org/license.txt for BSD license
USING: accessors assocs calendar combinators fonts formatting io
io.streams.string kernel literals make math math.order
namespaces pdf.canvas pdf.values pdf.wrap ranges sequences
sequences.extras sorting splitting ui.text xml.entities ;
FROM: pdf.canvas => draw-text ;

IN: pdf.layout

! TODO: inset, image
! Insets:
! before:
!   y += inset-height
!   margin-left, margin-right += inset-width
! after:
!   y += inset-height
!   margin-left, margin-right -= inset-width

! TUPLE: pre < p
! C: <pre> pre

! TUPLE: spacer width height ;
! C: <spacer> spacer

! TUPLE: image < span ;
! C: <image> image

! Outlines (add to catalog):
!   /Outlines 3 0 R
!   /PageMode /UseOutlines
! Table of Contents
! Thumbnails
! Annotations
! Images

! FIXME: spacing oddities if run multiple times
! FIXME: make sure highlights text "in order"
! FIXME: don't modify layout objects in pdf-render
! FIXME: make sure unicode "works"
! FIXME: only set style differences to reduce size?
! FIXME: gadget. to take a "screenshot" into a pdf?
! FIXME: compress each pdf object to reduce file size?


GENERIC: pdf-render ( canvas obj -- remain/f )

M: f pdf-render 2drop f ;

GENERIC: pdf-width ( canvas obj -- n )

<PRIVATE

: (pdf-layout) ( page obj -- page )
    [ ] [
        dupd [ pdf-render ] with-string-writer
        '[ _ append ] [ change-stream ] curry dip
        [ [ , <canvas> ] when ] keep
    ] while* ;

PRIVATE>

: pdf-layout ( seq -- pages )
    [ <canvas> ] dip [
        [ (pdf-layout) ] each
        dup stream>> empty? [ drop ] [ , ] if
    ] { } make ;


TUPLE: div items style ;

C: <div> div

M: div pdf-render
    [ style>> set-style ] keep
    swap '[ _ pdf-render drop ] each f ;

M: div pdf-width
    [ style>> set-style ] keep
    items>> [ dupd pdf-width ] map nip maximum ;


<PRIVATE

: convert-string ( str -- str' )
    {
        { CHAR: “    "\""   }
        { CHAR: ”    "\""   }
    } escape-string-by [ 256 < ] filter ;

PRIVATE>


TUPLE: p string style ;

: <p> ( string style -- p )
    [ convert-string ] dip p boa ;

M: p pdf-render
    [ style>> set-style ] keep
    [
        over ?line-break
        over [ font>> ] [ avail-width ] bi visual-wrap
        over avail-lines index-or-length cut
        [ draw-text ] [ "" concat-as ] bi*
    ] change-string dup string>> empty? [ drop f ] when ;

M: p pdf-width
    [ style>> set-style ] keep
    [ font>> ] [ string>> ] bi* split-lines
    [ dupd text-width ] map nip maximum ;


TUPLE: text string style ;

: <text> ( string style -- text )
    [ convert-string ] dip text boa ;

! FIXME: need to make links clickable, render text first, draw
! box over text that is "link"

! https://www.w3.org/WAI/WCAG21/Techniques/pdf/PDF11.html

M: text pdf-render
    [ style>> set-style ] keep
    [
        over x>> 0 > [
            2dup text-fits? [
                over [ font>> ] [ avail-width ] bi visual-wrap
                unclip [ "" concat-as ] dip
            ] [ over line-break f ] if
        ] [ f ] if
        [
            [ { } ] [ over [ font>> ] [ width ] bi visual-wrap ]
            if-empty
        ] dip [ prefix ] when*
        over avail-lines index-or-length cut
        [ draw-text ] [ "" concat-as ] bi*
    ] change-string dup string>> empty? [ drop f ] when ;

M: text pdf-width
    [ style>> set-style ] keep
    [ font>> ] [ string>> ] bi* split-lines
    [ dupd text-width ] map nip maximum ;


TUPLE: hr width ;

C: <hr> hr

M: hr pdf-render
    [ f set-style ] dip
    [
        [ dup 0 > pick avail-lines 0 > and ] [
            over avail-width over min [ - ] keep [
                overd [ draw-line ] [ inc-x ] 2bi
            ] unless-zero dup 0 > [ over line-break ] when
        ] while
    ] change-width nip dup width>> 0 > [ drop f ] unless ;

M: hr pdf-width
    nip width>> ;


TUPLE: br ;

C: <br> br

M: br pdf-render
    [ f set-style ] dip
    over avail-lines 0 > [ drop ?break f ] [ nip ] if ;

M: br pdf-width
    2drop 0 ;


TUPLE: pb used? ;

: <pb> ( -- pb ) f pb boa ;

M: pb pdf-render
    dup used?>> [ f >>used? drop f ] [ t >>used? ] if nip ;

M: pb pdf-width
    2drop 0 ;



CONSTANT: table-cell-padding 5

TUPLE: table-cell contents width ;

: <table-cell> ( contents -- table-cell )
    f table-cell boa ;

M: table-cell pdf-render
    {
        [ width>> >>col-width 0 >>x drop ]
        [
            [ [ dupd pdf-render ] map nip ] change-contents
            dup contents>> [ ] any? [ drop f ] unless
        ]
        [
            width>> table-cell-padding +
            swap margin>> [ + ] change-left drop
        ]
    } 2cleave ;

TUPLE: table-row cells ;

C: <table-row> table-row

! save y before rendering each cell
! set y to max y after all renders

M: table-row pdf-render
    {
        [ drop ?line-break ]
        [
            [let
                over y>> :> start-y
                over y>> :> max-y!
                [
                    [
                        [ start-y >>y ] dip
                        dupd pdf-render
                        over y>> max-y max max-y!
                    ] map swap max-y >>y drop
                ] change-cells

                dup cells>> [ ] any? [ drop f ] unless
            ]
        ]
        [ drop margin>> 54 >>left drop ]
        [
            drop dup width>> >>col-width
            [ ?line-break ] [ table-cell-padding inc-y ] bi
        ]
    } 2cleave ;

: col-widths ( canvas cells -- widths )
    [
        [
            contents>> [ 0 ] [
                [ [ dupd pdf-width ] [ 0 ] if* ] map maximum
            ] if-empty
        ] [ 0 ] if*
    ] map nip ;

:: max-col-widths ( canvas rows -- widths )
    H{ } clone :> widths
    rows [
        cells>> canvas swap col-widths
        [ widths [ 0 or max ] change-at ] each-index
    ] each widths sort-keys values

    dup sum dup 450 > [

        over first 150 < [
            ! special-case small first column
            drop dup unclip-slice over sum swap
            450 swap - swap / [ * ] curry map! drop
        ] [
            ! size down all columns
            450 swap / [ * ] curry map
        ] if

    ] [
        ! make last cell larger
        450 swap [-] [ + ] curry dupd
        sequences.extras:change-last
    ] if ;

: set-col-widths ( canvas rows -- )
    [ max-col-widths ] keep [
        dupd cells>> [
            [ swap >>width drop ] [ drop ] if*
        ] 2each
    ] each drop ;

TUPLE: table rows widths? ;

: <table> ( rows -- table )
    f table boa ;

M: table pdf-render
    {
        [
            dup widths?>> [ 2drop ] [
                t >>widths? rows>> set-col-widths
            ] if
        ]
        [
            [
                dup rows>> empty? [ t ] [
                    [ rows>> first dupd pdf-render ] keep swap
                ] if
            ] [ [ rest ] change-rows ] until nip
            dup rows>> [ drop f ] [ drop ] if-empty
        ]
    } 2cleave ;

M: table pdf-width
    2drop 450 ; ! FIXME: hardcoded max-width


: pdf-object ( str n -- str' )
    "%d 0 obj\n" sprintf "\nendobj" surround ;

: pdf-stream ( str -- str' )
    [ length 1 + "<<\n/Length %d\n>>" sprintf ]
    [ "\nstream\n" "\nendstream" surround ] bi append ;

: pdf-catalog ( -- str )
    {
        "<<"
        "/Type /Catalog"
        "/Pages 15 0 R"
        ">>"
    } join-lines ;

: pdf-pages ( n -- str )
    [
        "<<" ,
        "/Type /Pages" ,
        "/MediaBox [ 0 0 612 792 ]" ,
        [ "/Count %d" sprintf , ]
        [
            16 swap 2 range boa
            [ "%d 0 R " sprintf ] map concat
            "/Kids [ " "]" surround ,
        ] bi
        ">>" ,
    ] { } make join-lines ;

: pdf-page ( n -- page )
    [
        "<<" ,
        "/Type /Page" ,
        "/Parent 15 0 R" ,
        1 + "/Contents %d 0 R" sprintf ,
        "/Resources << /Font <<" ,
        "/F1 3 0 R /F2 4 0 R /F3 5 0 R" ,
        "/F4 6 0 R /F5 7 0 R /F6 8 0 R" ,
        "/F7 9 0 R /F8 10 0 R /F9 11 0 R" ,
        "/F10 12 0 R /F11 13 0 R /F12 14 0 R" ,
        ">> >>" ,
        ">>" ,
    ] { } make join-lines ;

: pdf-trailer ( objects -- str )
    [
        "xref" ,
        dup length 1 + "0 %d" sprintf ,
        "0000000000 65535 f" ,
        9 over [
            over "%010X 00000 n" sprintf , length 1 + +
        ] each drop
        "trailer" ,
        "<<" ,
        dup length 1 + "/Size %d" sprintf ,
        "/Info 1 0 R" ,
        "/Root 2 0 R" ,
        ">>" ,
        "startxref" ,
        [ length 1 + ] map-sum 9 + "%d" sprintf ,
        "%%EOF" ,
    ] { } make join-lines ;

SYMBOLS: pdf-producer pdf-author pdf-creator ;

TUPLE: pdf-info title timestamp producer author creator ;

: <pdf-info> ( -- pdf-info )
    pdf-info new
        now >>timestamp
        pdf-producer get >>producer
        pdf-author get >>author
        pdf-creator get >>creator ;

M: pdf-info pdf-value
    [
        "<<" print [
            [ timestamp>> [ "/CreationDate " write pdf-write nl ] when* ]
            [ producer>> [ "/Producer " write pdf-write nl ] when* ]
            [ author>> [ "/Author " write pdf-write nl ] when* ]
            [ title>> [ "/Title " write pdf-write nl ] when* ]
            [ creator>> [ "/Creator " write pdf-write nl ] when* ]
        ] cleave ">>" print
    ] with-string-writer ;


TUPLE: pdf-ref object revision ;

C: <pdf-ref> pdf-ref

M: pdf-ref pdf-value
    [ object>> ] [ revision>> ] bi "%d %d R" sprintf ;


TUPLE: pdf info pages fonts ;

: <pdf> ( -- pdf )
    pdf new
        <pdf-info> >>info
        V{ } clone >>pages
        V{ } clone >>fonts ;

:: pages>objects ( pdf -- objects )
    [
        pdf info>> pdf-value ,
        pdf-catalog ,
        { $ sans-serif-font $ serif-font $ monospace-font } {
            [ [ f >>bold? f >>italic? pdf-value , ] each ]
            [ [ t >>bold? f >>italic? pdf-value , ] each ]
            [ [ f >>bold? t >>italic? pdf-value , ] each ]
            [ [ t >>bold? t >>italic? pdf-value , ] each ]
        } cleave
        pdf pages>> length pdf-pages ,
        pdf pages>>
        dup length 16 swap 2 range boa zip
        [ pdf-page , , ] assoc-each
    ] { } make
    dup length [1..b] zip [ first2 pdf-object ] map ;

: objects>pdf ( objects -- str )
    [ join-lines "\n" append "%PDF-1.4\n" ]
    [ pdf-trailer ] bi surround ;

! Rename to pdf>string, have it take a <pdf> object?

: pdf>string ( seq -- pdf )
    <pdf> swap pdf-layout  [
        stream>> pdf-stream over pages>> push
    ] each pages>objects objects>pdf ;

: write-pdf ( seq -- )
    pdf>string write ;
