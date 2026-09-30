USING: accessors assocs calendar combinators io.streams.string io.styles kernel
metar metar.private namespaces sequences splitting tools.test ;

{ { "RAB05" "E30" "SNB20" "E55" } }
[ "RAB05E30SNB20E55" split-recent-weather ] unit-test

{ "calm" } [ "00000KT" parse-wind ] unit-test
{ "calm" } [ "00000MPS" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "36005KT" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "360/5KT" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "36005MPS" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "360/5MPS" parse-wind ] unit-test

{ "1 1/2 statute miles" } [ "1 1/2SM" parse-visibility ] unit-test
{ "100m" } [ "0100" parse-visibility ] unit-test
{ "4.2km" } [ "4200" parse-visibility ] unit-test
{ "5km" } [ "5000" parse-visibility ] unit-test
{ "10km or more" } [ "9999" parse-visibility ] unit-test
{ "10km or more north" } [ "9999N" parse-visibility ] unit-test

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

! Weather groups must not consume cloud or status tokens.
{ "heavy thunderstorm rain snow" } [ "+TSRASN" parse-weather ] unit-test
{ "recent thunderstorm rain" } [ "RETSRA" parse-weather ] unit-test
{ "thunderstorm in the vicinity" } [ "VCTS" parse-weather ] unit-test
{ f f f t } [
    "FEW020" weather-group? "NIL" weather-group?
    "AUTO" weather-group? "NSW" weather-group?
] unit-test
{ "vertical visibility at 300 ft" } [ "VV003" parse-sky-condition ] unit-test
{ "vertical visibility at unknown height" } [ "VV///" parse-sky-condition ] unit-test
{ "overcast at 1000 ft (cumulonimbus)" } [ "OVC010CB" parse-sky-condition ] unit-test
{ "broken at unknown height (towering cumulus)" } [ "BKN///TCU" parse-sky-condition ] unit-test
{ "runway 28L visibility of less than 600 ft" } [ "R28L/M0600FT" parse-rvr ] unit-test
{ "runway 01 visibility varying between less than 600 and more than 2000 meters with improvement" }
[ "R01/M0600VP2000U" parse-rvr ] unit-test
{ "from W (270°) at 20 kilometers per hour" } [ "27020KMH" parse-wind ] unit-test
{ "sea-level pressure is 999.8 hPa" } [ "SLP998" parse-sea-level-pressure ] unit-test
{ "sea-level pressure is 1004.5 hPa" } [ "SLP045" parse-sea-level-pressure ] unit-test
{ "UNKNOWN" } [ "UNKNOWN" parse-glossary ] unit-test
{ "relative humidity 41%" } [ "RH/41" parse-remark ] unit-test
{ "wind shift at 22:44 frontal passage varying between 4300 and 8000 ft" }
[ { "WSHFT" "2244" "FROPA" "CIG" "043V080" } decode-remarks ] unit-test

! Calendar rollover, including 24:00 and leap days, uses a fixed UTC reference.
{ 2026 10 1 0 0 } [
    "010000" 2026 9 30 23 0 0 instant <timestamp> parse-timestamp-at
    { [ year>> ] [ month>> ] [ day>> ] [ hour>> ] [ minute>> ] } cleave
] unit-test
{ 2024 3 1 } [
    "292400" 2024 3 1 <date-utc> parse-timestamp-at
    [ year>> ] [ month>> ] [ day>> ] tri
] unit-test

{ "METAR" "KPIT" "thunderstorm rain" "overcast at 1000 ft (cumulonimbus)" { } } [
    "METAR KPIT 091955Z COR 22015G25KT 3/4SM R28L/2600FT TSRA OVC010CB 18/16 A2992 RMK SLP045 T01820159"
    <metar-report> { [ type>> ] [ station>> ] [ weather>> ]
      [ sky-condition>> ] [ unparsed>> ] } cleave
] unit-test
{ "10km or more" "no significant weather" "no significant cloud" { "UNRECOGNIZED" } } [
    "METAR EGLL 091950Z 27010KT CAVOK 15/10 Q1013 UNRECOGNIZED="
    <metar-report> { [ visibility>> ] [ weather>> ] [ sky-condition>> ] [ unparsed>> ] } cleave
] unit-test
{ "NIL" } [ "METAR EGLL 091950Z NIL=" <metar-report> status>> ] unit-test
{ "AMD" "CNL" } [ "TAF AMD EGLL 091700Z 0918/1024 CNL=" <taf-report>
    [ modifier>> ] [ status>> ] bi ] unit-test
{ "1 1/2 statute miles" } [
    "TAF EGLL 091700Z 0918/1024 27010KT 1 1/2SM BKN010"
    <taf-report> visibility>>
] unit-test
{ { "FM" "TEMPO" "PROB" "FM" "BECMG" } } [
    "TAF KPIT 091730Z 0918/1024 15005KT 5SM HZ FEW020 WS010/31022KT FM091930 30015G25KT 3SM SHRA OVC015 TEMPO 0920/0922 1/2SM +TSRA OVC008CB PROB30 1004/1007 1SM -RA BR FM101015 18005KT 6SM -SHRA OVC020 BECMG 1013/1015 P6SM NSW SKC="
    <taf-report> partials>> [ change>> ] map
] unit-test
{ 40 "TEMPO" "wind shear from NW (310°) at 22 knots (25.3 mph) at 1000 ft" } [
    "TAF EGLL 091700Z 0918/1024 27010KT P6SM SCT020 PROB40 TEMPO 0920/0922 1SM TSRA BKN010CB WS010/31022KT"
    <taf-report> partials>> first
    [ probability>> ] [ change>> ] [ wind-shear>> ] tri
] unit-test
{ { "NOSIG" } } [ "METAR EGLL 091950Z 27010KT 9999 SCT020 15/10 Q1013 NOSIG="
    <metar-report> trend>> [ change>> ] map ] unit-test
{ "KPIT" } [
    "2026/09/09 17:30\nTAF\nKPIT 091730Z 0918/1024 15005KT P6SM SKC"
    <taf-report> station>>
] unit-test

{ "runway 16R: compacted or rolled snow; 11% to 25% covered; depth 33 mm; friction coefficient 0.09" }
[ "66823309" parse-runway-state ] unit-test
{ "runway 16R: compacted or rolled snow; 11% to 25% covered; depth 33 mm; friction coefficient 0.09" }
[ "R16R/823309" parse-runway-state ] unit-test
{ "all runways cleared; braking conditions not reported" }
[ "R88/CLRD//" parse-runway-state ] unit-test
{ "all runways: dry snow; 51% to 100% covered; depth not reported; braking action poor" }
[ "8849//91" parse-runway-state ] unit-test
{ "seas 1 to 3 feet" } [ { "SEAS" "1-3" } decode-remarks ] unit-test
{ "peak wind from W (270°) at 35 knots (40.3 mph) occurring at 12:30" }
[ { "PK" "WND" "27035/1230" } decode-remarks ] unit-test
{ "light rime icing in cloud, base 3000 ft, depth 4000 ft" }
[ "620304" parse-layer-forecast ] unit-test
{ "from W (270°) at more than 99 knots (113.9 mph)" }
[ "270P99KT" parse-wind ] unit-test
{ "station with a precipitation discriminator" }
[ "AO2" metar-abbreviation ] unit-test
{ f } [ "UNRECOGNIZED" metar-abbreviation ] unit-test
{ "2.0km" } [ "2000NDV" parse-visibility ] unit-test
{ "30 °C (86.0 °F)" } [ "30/" parse-temperature drop ] unit-test
{ "maximum temperature 30 °C (86.0 °F) at" } [
    "TX30/1012Z" parse-forecast-temperature " at" split1 drop " at" append
] unit-test

{ "unknown direction at 5 knots (5.8 mph)" } [ "///05KT" parse-wind ] unit-test
{ "from W (270°) at unknown speed" } [ "270//KT" parse-wind ] unit-test
{ "unknown direction at unknown speed" } [ "/////KT" parse-wind ] unit-test
{ f "3 °C (37.4 °F)" } [ "///03" parse-temperature ] unit-test
{ "10 °C (50.0 °F)" f } [ "10///" parse-temperature ] unit-test
{ f f } [ "/////" parse-temperature ] unit-test
{ "altimeter unavailable" } [ "Q////" parse-altimeter ] unit-test
{ "visibility unavailable" } [ "////" parse-visibility ] unit-test
{ "sea-surface temperature 19 °C (66.2 °F); sea state moderate" }
[ "W19/S4" parse-sea-condition ] unit-test
{ "sea-surface temperature 12 °C (53.6 °F); significant wave height 7.5 meters" }
[ "W12/H75" parse-sea-condition ] unit-test
{ "sea-surface temperature unavailable; sea state moderate" }
[ "W///S4" parse-sea-condition ] unit-test
{ "wind shear on runway 24" { } } [
    "SPECI LUDO 211025Z 31015G27KT 280V350 4000 1400SW R24/P2000 +SHRA FEW005 FEW010CB SCT018 BKN025 10/03 Q0995 RERA WS R24 W19/S4"
    parse-metar [ wind-shear>> ] [ unparsed>> ] bi
] unit-test
{ "wind shear on all runways" } [
    "METAR EGLL 211025Z 27010KT CAVOK 10/03 Q0995 WS ALL RWY"
    parse-metar wind-shear>>
] unit-test

{ 2026 9 9 } [
    "2026/09/09 17:30\nTAF KPIT 091730Z 0918/1024 15005KT P6SM SKC"
    report-anchor [ year>> ] [ month>> ] [ day>> ] tri
] unit-test

{ "runway 24 visibility of unavailable meters" }
[ "R24/////" parse-rvr ] unit-test
{ "extreme turbulence, base 3000 ft, depth 4000 ft" }
[ "5X0304" parse-layer-forecast ] unit-test
{ t t } [
    [ "METAR EGLL 211025Z 27010KT CAVOK 10/03 Q0995 NOSIG"
      parse-metar metar-report. ] with-string-writer
    [ "Change" subseq-of? ] [ "NOSIG" subseq-of? ] bi
] unit-test

{ t t } [
    [ "TAF EGLL 211000Z 2112/2212 27010KT CAVOK PROB40 TEMPO 2114/2116 1000 TSRA BKN010CB"
      parse-taf taf-report. ] with-string-writer
    [ "Probability" subseq-of? ] [ "40" subseq-of? ] bi
] unit-test

{ "less than 50m" } [ "0000" parse-visibility ] unit-test
