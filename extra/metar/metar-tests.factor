USING: io.streams.string io.styles metar.private sequences tools.test ;

{ { "RAB05" "E30" "SNB20" "E55" } }
[ "RAB05E30SNB20E55" split-recent-weather ] unit-test

{ "calm" } [ "00000KT" parse-wind ] unit-test
{ "calm" } [ "00000MPS" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "36005KT" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "360/5KT" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "36005MPS" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "360/5MPS" parse-wind ] unit-test

{ "1+1/2 statute miles" } [ "1 1/2SM" parse-visibility ] unit-test
{ "100m" } [ "0100" parse-visibility ] unit-test
{ "4.2km" } [ "4200" parse-visibility ] unit-test
{ "5km" } [ "5000" parse-visibility ] unit-test
{ "more than 10km" } [ "9999" parse-visibility ] unit-test
{ "more than 10km north" } [ "9999N" parse-visibility ] unit-test

{ "Label value" } [
    [ standard-table-style [ "Label" [ "value" ] row. ] tabular-output ]
    with-string-writer
] unit-test

{ "Empty " } [
    [ standard-table-style [ "Empty" [ f ] row. ] tabular-output ]
    with-string-writer
] unit-test

{ "Long abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij abcdefghij\n     abcdefghij abcdefghij" } [
    [ standard-table-style [
        "Long" [ 8 "abcdefghij " <repetition> concat ] row.
    ] tabular-output ] with-string-writer
] unit-test
