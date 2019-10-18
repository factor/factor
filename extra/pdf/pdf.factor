! Copyright (C) 2007 Elie CHAFTARI
! See http://factorcode.org/license.txt for BSD license.
!
! Tested with libharu2 2.0.8 on Mac OS X 10.4.9 PowerPC

USING: assocs continuations hashtables kernel math namespaces pdf.libhpdf ;

IN: pdf

SYMBOL: pdf
SYMBOL: page

! =========================================================
! Error handling routines
! =========================================================

: check-status ( status -- )
    dup zero? [ 
        drop
    ] [
        error-code >hashtable at throw   
    ] if ;

! =========================================================
! Document handling routines
! =========================================================

: new-pdf ( error-handler user-data -- )
    HPDF_New pdf set ;

: free-pdf ( -- )
    pdf get HPDF_Free drop ;

: with-pdf ( quot -- )
    [ f f new-pdf [ free-pdf ] [ ] cleanup ] with-scope ; inline

: set-compression-mode ( mode -- )
    pdf get swap HPDF_SetCompressionMode check-status ;

: set-page-mode ( mode -- )
    pdf get swap HPDF_SetPageMode check-status ;

: add-page ( -- )
    pdf get HPDF_AddPage page set ;

: save-to-file ( filename -- )
    pdf get swap HPDF_SaveToFile check-status ;

: get-font ( fontname encoding -- font )
    pdf get -rot HPDF_GetFont ;

! =========================================================
! Page Handling routines
! =========================================================

: get-page-height ( -- height )
    page get HPDF_Page_GetHeight ;

: get-page-width ( -- width )
    page get HPDF_Page_GetWidth ;

: page-text-width ( text -- width )
    page get swap HPDF_Page_TextWidth ;

! =========================================================
! Graphics routines
! =========================================================

: set-page-line-width ( linewidth -- )
    page get swap HPDF_Page_SetLineWidth check-status ;

: page-rectangle ( x y width height -- )
    >r >r >r >r page get r> r> r> r> HPDF_Page_Rectangle check-status ;

: page-stroke ( -- )
    page get HPDF_Page_Stroke check-status ;

: set-page-font-and-size ( font size -- )
    page get -rot HPDF_Page_SetFontAndSize check-status ;

: page-begin-text ( -- )
    page get HPDF_Page_BeginText check-status ;

: page-text-out ( xpos ypos text -- )
    page get -roll HPDF_Page_TextOut check-status ;

: page-end-text ( -- )
    page get HPDF_Page_EndText check-status ;

: with-text ( -- )
    [ page-begin-text [ page-end-text ] [ ] cleanup ] with-scope ; inline

: page-move-text-pos ( x y -- )
    page get -rot HPDF_Page_MoveTextPos check-status ;

: page-show-text ( text -- )
    page get swap HPDF_Page_ShowText check-status ;
