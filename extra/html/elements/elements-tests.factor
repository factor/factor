IN: temporary
USING: tools.test html html.elements io.streams.string ;

: make-html-string
    [ with-html-stream ] string-out ;

[ "<a href='h&amp;o'>" ]
[ [ <a "h&o" =href a> ] make-html-string ] unit-test
