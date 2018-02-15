USING: tools.test html.elements io.streams.string ;

{ "<a href='h&amp;o'>" }
[ [ <a "h&o" =href a> ] with-string-writer ] unit-test
