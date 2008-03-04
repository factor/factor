USING: alien.syntax kernel math prettyprint
combinators vocabs.loader hardware-info.backend system ;
IN: hardware-info

: kb. ( x -- ) 10 2^ /f . ;
: megs. ( x -- ) 20 2^ /f . ;
: gigs. ( x -- ) 30 2^ /f . ;

<<
{
    { [ windows? ] [ "hardware-info.windows" ] }
    { [ linux? ] [ "hardware-info.linux" ] }
    { [ macosx? ] [ "hardware-info.macosx" ] }
    { [ t ] [ f ] }
} cond [ require ] when* >>

