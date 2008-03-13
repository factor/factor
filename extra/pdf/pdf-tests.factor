USING: io.files kernel math namespaces pdf pdf.libhpdf prettyprint sequences ;
IN: pdf.tests

SYMBOL: font

SYMBOL: width
SYMBOL: height
SYMBOL: twidth

: font-list ( -- seq ) {
    "Courier"
    "Courier-Bold"
    "Courier-Oblique"
    "Courier-BoldOblique"
    "Helvetica"
    "Helvetica-Bold"
    "Helvetica-Oblique"
    "Helvetica-BoldOblique"
    "Times-Roman"
    "Times-Bold"
    "Times-Italic"
    "Times-BoldItalic"
    "Symbol"
    "ZapfDingbats"
} ;

[
    ! HPDF_COMP_ALL set-compression-mode

    ! HPDF_PAGE_MODE_USE_OUTLINE set-page-mode

    ! Add a new page object
    add-page

    get-page-height height set

    get-page-width width set

    ! Print the lines of the page
    1 set-page-line-width

    50 50 width get 100 - height get 110 - page-rectangle

    page-stroke

    ! Print the title of the page (with positioning center)
    "Helvetica" f get-font font set

    font get 24 set-page-font-and-size

    "Font Demo" page-text-width twidth set

    [
        width get twidth get - 2 / height get 50 - "Font Demo" page-text-out

    ] with-text

    ! Print subtitle
    [
        font get 16 set-page-font-and-size

        60 height get 80 - "<Standard Type1 font samples>" page-text-out

    ] with-text

    ! Print font list
    [
        60 height get 105 - page-move-text-pos

        SYMBOL: fontname

        font-list [

            fontname set

            fontname get f get-font font set

            ! print a label of text
            font get 9 set-page-font-and-size

            fontname get page-show-text

            0 -18 page-move-text-pos

            ! print a sample text
            font get 20 set-page-font-and-size

            "abcdefgABCDEFG12345!#$%&+-@?" page-show-text

            0 -20 page-move-text-pos

        ] each

    ] with-text

    "font_test.pdf" temp-file save-to-file

] with-pdf
