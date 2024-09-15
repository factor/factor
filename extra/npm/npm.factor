! Copyright (C) 2023 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays assocs concurrency.combinators continuations
github hashtables http.client io.encodings.string
io.encodings.utf8 json kernel math.order semver sequences
sorting.specification splitting strings ;
IN: npm

MEMO: get-npm-json ( name -- json )
    "https://registry.npmjs.org/" prepend
    [ http-get-json nip ] [ 2drop H{ } clone ] recover ;

! "@babel/core-7.12": "npm:@babel/core@7.12.9"
: dep-names8 ( deps -- dep-names )
    [ nip "npm:" head? not ] assoc-partition
    [ keys ] [
        values [
            "npm:" ?head drop dup
            [ CHAR: @ = ] find-last
            [ head ] [ drop ] if
        ] map
    ] bi* append ;

GENERIC: deps ( obj -- seq )
M: hashtable deps "dependencies" of { } or ;
M: string deps get-npm-json deps ;

GENERIC: dev-deps ( obj -- seq )
M: hashtable dev-deps "devDependencies" of { } or ;
M: string dev-deps get-npm-json dev-deps ;
M: f dev-deps drop { } ;

: npm-versions ( name -- version ) get-npm-json "versions" of ;
: npm-time ( name -- version ) get-npm-json "time" of ;

: sort-versions-asc ( versions -- versions' ) { { >semver <=> } } sort-keys-with-spec keys ;
: sort-versions-dsc ( versions -- versions' ) { { >semver >=< } } sort-keys-with-spec keys ;
: npm-latest-version ( name -- version )
    [ npm-versions ] [ npm-versions sort-versions-asc ?last ] bi of ;

: ?github-package-json ( owner repo -- json/f )
    '[ _ _ "package.json" github-file-contents json> ]
    [ drop f ] recover ;

: github-package-json-latest ( owner repo -- json/f )
    ?github-package-json [
        [ "dependencies" of ] [ "devDependencies" of ] bi 2array [
            [ over npm-latest-version "version" of 2array ] parallel-assoc-map
            [ first2 = not ] filter-values
        ] map
    ] transmute ;
