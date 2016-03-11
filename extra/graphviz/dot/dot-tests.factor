USING: graphviz.dot.private io.streams.string sequences tools.test ;
IN: graphviz.dot.tests

! Making sure strings are escaped properly
{
    {
        "\"BAH\" "
        "\"LINE1\\nLINE2\" "
        "\"\\lLINE1\\lLINE2\" "
        "\"hum\\\"ho\\\"\" "
    }
} [
    {
        "BAH"
        "LINE1\\nLINE2"
        "\\lLINE1\\lLINE2"
        "hum\"ho\""
    } [
        [ dot. ] with-string-writer
    ] map
] unit-test
