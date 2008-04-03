USING: alien.syntax kernel math prettyprint
combinators vocabs.loader hardware-info.backend system ;
IN: hardware-info

: kb. ( x -- ) 10 2^ /f . ;
: megs. ( x -- ) 20 2^ /f . ;
: gigs. ( x -- ) 30 2^ /f . ;

<< {
    { [ os windows? ] [ "hardware-info.windows" ] }
    { [ os linux? ] [ "hardware-info.linux" ] }
    { [ os macosx? ] [ "hardware-info.macosx" ] }
    { [ t ] [ f ] }
} cond [ require ] when* >>
