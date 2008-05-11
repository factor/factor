USING: cairo math.parser kernel sequences tools.test ;
IN: cairo.tests

[ t ] [ ! apply a little pressure to cairo_version
    cairo_version number>string CHAR: 0 swap remove
    CHAR: . cairo_version_string remove =
] unit-test