! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.format
classes.tuple combinators command-line continuations csv
formatting grouping http.client io io.encodings.ascii io.files
io.styles kernel math math.extras math.functions math.parser
namespaces regexp sequences sorting.human splitting strings urls
wrap.strings ;

IN: metar

TUPLE: station cccc name state country latitude longitude ;

C: <station> station

<PRIVATE

ERROR: bad-location str ;

: parse-location ( str -- n )
    "-" split dup length {
        { 3 [ first3 [ string>number ] tri@ 60.0 / + 60.0 / + ] }
        { 2 [ first2 [ string>number ] bi@ 60.0 / + ] }
        { 1 [ first string>number ] }
        [ drop bad-location ]
    } case ;

: string>longitude ( str -- lon/f )
    dup R/ \d+-\d+(-\d+(\.\d+)?)?[WE]/ matches? [
        unclip-last
        [ parse-location ]
        [ CHAR: W = [ neg ] when ] bi*
    ] [ drop f ] if ;

: string>latitude ( str -- lat/f )
    dup R/ \d+-\d+(-\d+(\.\d+)?)?[NS]/ matches? [
        unclip-last
        [ parse-location ]
        [ CHAR: S = [ neg ] when ] bi*
    ] [ drop f ] if ;

: stations-data ( -- seq )
    URL" https://tgftp.nws.noaa.gov/data/nsd_cccc.txt"
    http-get nip CHAR: ; [ string>csv ] with-delimiter ;

PRIVATE>

MEMO: all-stations ( -- seq )
    stations-data [
        {
            [ 0 swap nth ]
            [ 3 swap nth ]
            [ 4 swap nth ]
            [ 5 swap nth ]
            [ 7 swap nth string>latitude ]
            [ 8 swap nth string>longitude ]
        } cleave <station>
    ] map ;

: all-stations. ( -- )
    all-stations standard-table-style [
        [
            [
                tuple-slots [
                    [
                        [
                            dup string? [ "%.2f" sprintf ] unless write
                        ] when*
                    ] with-cell
                ] each
            ] with-row
        ] each
    ] tabular-output nl ;

: find-by-cccc ( cccc -- station )
    all-stations swap '[ cccc>> _ = ] find nip ;

: find-by-country ( country -- stations )
    all-stations swap '[ country>> _ = ] filter ;

: find-by-state ( state -- stations )
    all-stations swap '[ state>> _ = ] filter ;

<PRIVATE

TUPLE: metar-report type station timestamp modifier wind
visibility rvr weather sky-condition temperature dew-point
altimeter remarks raw ;

CONSTANT: pressure-tendency H{
    { "0" "increasing then decreasing" }
    { "1" "increasing more slowly" }
    { "2" "increasing" }
    { "3" "increasing more quickly" }
    { "4" "steady" }
    { "5" "decreasing then increasing" }
    { "6" "decreasing more slowly" }
    { "7" "decreasing" }
    { "8" "decreasing more quickly" }
}

CONSTANT: lightning H{
    { "CA" "cloud-air lightning" }
    { "CC" "cloud-cloud lightning" }
    { "CG" "cloud-ground lightning" }
    { "IC" "in-cloud lightning" }
}

CONSTANT: weather H{
    { "BC" "patches" }
    { "BL" "blowing" }
    { "BR" "mist" }
    { "DR" "low drifting" }
    { "DS" "duststorm" }
    { "DU" "widespread dust" }
    { "DZ" "drizzle" }
    { "FC" "funnel clouds" }
    { "FG" "fog" }
    { "FU" "smoke" }
    { "FZ" "freezing" }
    { "GR" "hail" }
    { "GS" "small hail and/or snow pellets" }
    { "HZ" "haze" }
    { "IC" "ice crystals" }
    { "MI" "shallow" }
    { "PL" "ice pellets" }
    { "PO" "well-developed dust/sand whirls" }
    { "PR" "partial" }
    { "PY" "spray" }
    { "RA" "rain" }
    { "RE" "recent" }
    { "SA" "sand" }
    { "SG" "snow grains" }
    { "SH" "showers" }
    { "SN" "snow" }
    { "SQ" "squalls" }
    { "SS" "sandstorm" }
    { "TS" "thuderstorm" }
    { "UP" "unknown" }
    { "VA" "volcanic ash" }
}

MEMO: glossary ( -- assoc )
    "vocab:metar/glossary.txt" ascii file-lines
    [ "," split1 ] H{ } map>assoc ;

: parse-glossary ( str -- str' )
    "/" split [
        find-numbers [
            dup number?
            [ number>string ]
            [ glossary ?at drop ] if
        ] map join-words
    ] map "/" join ;

: parse-timestamp ( str -- str' )
    [ now [ year>> ] [ month>> ] bi ] dip
    2 cut 2 cut 2 cut drop [ string>number ] tri@
    over 24 = [
        [ drop 0 ] dip 0 instant <timestamp> 1 days time+
    ] [
        0 instant <timestamp>
    ] if timestamp>rfc822 ;

CONSTANT: compass-directions H{
    { 0.0 "N" }
    { 22.5 "NNE" }
    { 45.0 "NE" }
    { 67.5 "ENE" }
    { 90.0 "E" }
    { 112.5 "ESE" }
    { 135.0 "SE" }
    { 157.5 "SSE" }
    { 180.0 "S" }
    { 202.5 "SSW" }
    { 225.0 "SW" }
    { 247.5 "WSW" }
    { 270.0 "W" }
    { 292.5 "WNW" }
    { 315.0 "NW" }
    { 337.5 "NNW" }
    { 360.0 "N" }
}

: direction>compass ( direction -- compass )
    22.5 round-to-step compass-directions at ;

: parse-compass ( str -- str' )
    string>number [ direction>compass ] keep "%s (%s°)" sprintf ;

: parse-direction ( str -- str' )
    dup "VRB" = [ drop "variable" ] [
        parse-compass "from %s" sprintf
    ] if ;

: kt>mph ( kt -- mph ) 1.15077945 * ;

: mph>kt ( mph -- kt ) 1.15077945 / ;

: parse-speed ( str units -- str'/f )
    [ string>number ] dip '[
        _ dup "knots" =
        [ drop dup kt>mph "%s knots (%.1f mph)" sprintf ]
        [ "%s %s" sprintf ] if
    ] [ f ] if* ;

: parse-wind ( str -- str' )
    dup "00000" head? [ drop "calm" ] [
        "/" split1 [ 3 cut ] unless*
        [ parse-direction ] dip {
            { [ "KT" ?tail ] [ "knots" ] }
            { [ "MPS" ?tail ] [ "meters per second" ] }
            [ "knots" ]
        } cond [ "G" split1 ] dip '[ _ parse-speed ] bi@
        [ "%s at %s with gusts to %s " sprintf ]
        [ "%s at %s" sprintf ] if*
    ] if ;

: parse-wind-variable ( str -- str' )
    "V" split1 [ parse-compass ] bi@
    ", variable from %s to %s" sprintf ;

: parse-visibility ( str -- str' )
    "SM" ?tail [
        dup first {
            { CHAR: M [ rest "less than " ] }
            { CHAR: P [ rest "more than " ] }
            [ drop "" ]
        } case swap
        CHAR: \s over index [ " " "+" replace ] when
        string>number "%s%s statute miles" sprintf
    ] [
        4 cut [
            string>number {
                { [ dup 800 < ] [ "%dm" sprintf ] }
                { [ dup 5000 < ] [ 1000 /f "%.1fkm" sprintf ] }
                { [ dup 9999 < ] [ 1000 /f "%dkm" sprintf ] }
                [ drop "more than 10km" ]
            } cond
        ] dip [
            [
                H{
                    { CHAR: N "north" }
                    { CHAR: E "east" }
                    { CHAR: S "south" }
                    { CHAR: W "west" }
                } at
            ] { } map-as unclip-last
            [ "-" join ] dip append " " glue
        ] unless-empty
    ] if ;

: parse-rvr ( str -- str' )
    {
        { [ "U" ?tail ] [ " with improvement" ] }
        { [ "D" ?tail ] [ " with aggravation" ] }
        { [ "N" ?tail ] [ " with no change" ] }
        [ "" ]
    } cond [
        "R" ?head drop "/" split1 "FT" ?tail [
            "V" split1 [
                [ string>number ] bi@
                "varying between %s and %s" sprintf
            ] [
                string>number "of %s" sprintf
            ] if* "runway %s visibility %s" sprintf
        ] dip " ft" " meters" ? append
    ] dip append ;

: (parse-weather) ( str -- str' )
    dup "+FC" = [ drop "tornadoes or waterspouts" ] [
        dup first {
            { CHAR: + [ rest "heavy " ] }
            { CHAR: - [ rest "light " ] }
            [ drop f ]
        } case [
            2 group dup [ weather key? ] all?
            [ [ weather at ] map join-words ]
            [ concat parse-glossary ] if
        ] dip prepend
    ] if ;

: parse-weather ( str -- str' )
    dup "VC" subseq-of? [ "VC" "" replace t ] [ f ] if
    [ (parse-weather) ]
    [ [ " in the vicinity" append ] when ] bi* ;

: parse-altitude ( str -- str' )
    string>number " at %s00 ft" sprintf ;

CONSTANT: sky H{
    { "BKN" "broken" }
    { "FEW" "few" }
    { "OVC" "overcast" }
    { "SCT" "scattered" }
    { "SKC" "clear sky" }
    { "CLR" "clear sky" }
    { "NSC" "clear sky" }

    { "ACC" "altocumulus castellanus" }
    { "ACSL" "standing lenticular altocumulus" }
    { "CCSL" "cirrocumulus standing lenticular cloud" }
    { "CU" "cumulus" }
    { "SC" "stratocumulus" }
    { "SCSL" "stratocumulus standing lenticular cloud" }
    { "TCU" "towering cumulus" }
}

: parse-sky-condition ( str -- str' )
    sky ?at [
        3 cut 3 cut
        [ sky at ]
        [ parse-altitude ]
        [ sky at [ " (%s)" sprintf ] [ f ] if* ]
        tri* 3append
    ] unless ;

: F>C ( F -- C ) 32 - 5/9 * ;

: C>F ( C -- F ) 9/5 * 32 + ;

: parse-temperature ( str -- temp dew-point )
    "/" split1 [
        [ f ] [
            "M" ?head [ string>number ] [ [ neg ] when ] bi*
            dup C>F "%d °C (%.1f °F)" sprintf
        ] if-empty
    ] bi@ ;

: parse-altimeter ( str -- str' )
    unclip [ string>number ] [ CHAR: A = ] bi*
    [ 100 /f "%.2f Hg" sprintf ] [ "%s hPa" sprintf ] if ;

CONSTANT: re-timestamp R/ \d{6}Z/
CONSTANT: re-station R/ \w{4}/
CONSTANT: re-temperature R/ [M]?\d{2}\/([M]?\d{2})?/
CONSTANT: re-wind R/ (VRB|\d{3})(\/\d+|\d{2,3})(G\d{2,3})?(KT|MPS)/
CONSTANT: re-wind-variable R/ \d{3}V\d{3}/
CONSTANT: re-visibility R/ ((\d+|[MP])?\d+(\/\d+)?SM|\d{4}[NSEW]{0,2})/
CONSTANT: re-rvr R/ R\d{2}[RLC]?\/[MP]?\d{4}(V\d{4})?(FT)?[UDN]?/
CONSTANT: re-weather R/ [+-]?(VC)?(\w{2}|\w{4})/
CONSTANT: re-sky-condition R/ (\w{2,3}\d{3}(\w+)?|\w{3}|CAVOK)/
CONSTANT: re-altimeter R/ [AQ]\d{4}/

: find-one ( seq quot: ( elt -- ? ) -- seq' elt/f )
    dupd find [ [ swap remove-nth ] when* ] dip ; inline

: find-all ( seq quot: ( elt -- ? ) -- seq elts )
    [ dupd find drop ] keep '[
        cut
        [ dup ?first _ [ f ] if* ] [ unclip ] produce
        [ append ] dip
    ] [ f ] if* ; inline

: fix-visibility ( seq -- seq' )
    dup [ R/ \d+(\/\d+)?SM/ matches? ] find drop [
        dup 1 - pick ?nth [ R/ \d+/ matches? ] [ f ] if* [
            cut [ unclip-last ] [ unclip swap ] bi*
            [ " " glue 1array ] [ 3append ] bi*
        ] [ drop ] if
    ] when* ;

: metar-body ( report seq -- report )
    [ { "METAR" "SPECI" } member? ] find-one
    [ pick type<< ] when*

    [ re-station matches? ] find-one
    [ pick station<< ] when*

    [ re-timestamp matches? ] find-one
    [ parse-timestamp pick timestamp<< ] when*

    [ { "AUTO" "COR" } member? ] find-one
    [ pick modifier<< ] when*

    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> prepend pick wind<< ] when*

    fix-visibility
    [ re-visibility matches? ] find-all
    [ parse-visibility ] map ", " join pick visibility<<

    [ re-rvr matches? ] find-all
    [ parse-rvr ] map ", " join pick rvr<<

    [ re-weather matches? ] find-all
    [ parse-weather ] map ", " join pick weather<<

    [ re-sky-condition matches? ] find-all
    [ parse-sky-condition ] map ", " join pick sky-condition<<

    [ re-temperature matches? ] find-one
    [
        parse-temperature
        [ pick temperature<< ]
        [ pick dew-point<< ] bi*
    ] when*

    [ re-altimeter matches? ] find-one
    [ parse-altimeter pick altimeter<< ] when*

    drop ;

: signed-number ( sign value -- n )
    [ string>number ] bi@ swap zero? [ neg ] unless 10.0 / ;

: single-value ( str -- str' )
    1 cut signed-number ;

: double-value ( str -- m n )
    1 cut 3 cut [ signed-number ] dip 1 cut signed-number ;

: parse-1hr-temp ( str -- str' )
    "T" ?head drop dup length 4 > [
        double-value
        [ dup C>F "%.1f °C (%.1f °F)" sprintf ] bi@
        "hourly temperature %s and dew point %s" sprintf
    ] [
        single-value dup C>F
        "hourly temperature %.1f °C (%.1f °F)" sprintf
    ] if ;

: parse-6hr-max-temp ( str -- str' )
    "1" ?head drop single-value dup C>F
    "6-hour maximum temperature %.1f °C (%.1f °F)" sprintf ;

: parse-6hr-min-temp ( str -- str' )
    "2" ?head drop single-value dup C>F
    "6-hour minimum temperature %.1f °C (%.1f °F)" sprintf ;

: parse-24hr-temp ( str -- str' )
    "4" ?head drop double-value
    [ dup C>F "%.1f °C (%.1f °F)" sprintf ] bi@
    "24-hour maximum temperature %s minimum temperature %s"
    sprintf ;

: parse-1hr-pressure ( str -- str' )
    "5" ?head drop 1 cut single-value [ pressure-tendency at ] dip
    "hourly pressure %s %s hPa" sprintf ;

: parse-snow-depth ( str -- str' )
    "4/" ?head drop string>number "snow depth %s inches" sprintf ;

CONSTANT: low-clouds H{
    { 1 "cumulus (fair weather)" }
    { 2 "cumulus (towering)" }
    { 3 "cumulonimbus (no anvil)" }
    { 4 "stratocumulus (from cumulus)" }
    { 5 "stratocumuls (not cumulus)" }
    { 6 "stratus or Fractostratus (fair)" }
    { 7 "fractocumulus / fractostratus (bad weather)" }
    { 8 "cumulus and stratocumulus" }
    { 9 "cumulonimbus (thunderstorm)" }
    { -1 "not valid" }
}

CONSTANT: mid-clouds H{
    { 1 "altostratus (thin)" }
    { 2 "altostratus (thick)" }
    { 3 "altocumulus (thin)" }
    { 4 "altocumulus (patchy)" }
    { 5 "altocumulus (thickening)" }
    { 6 "altocumulus (from cumulus)" }
    { 7 "altocumulus (with altocumulus, altostratus, nimbostratus)" }
    { 8 "altocumulus (with turrets)" }
    { 9 "altocumulus (chaotic)" }
    { -1 "above overcast" }
}

CONSTANT: high-clouds H{
    { 1 "cirrus (filaments)" }
    { 2 "cirrus (dense)" }
    { 3 "cirrus (often with cumulonimbus)" }
    { 4 "cirrus (thickening)" }
    { 5 "cirrus / cirrostratus (low in sky)" }
    { 6 "cirrus / cirrostratus (hi in sky)" }
    { 7 "cirrostratus (entire sky)" }
    { 8 "cirrostratus (partial)" }
    { 9 "cirrocumulus or cirrocumulus / cirrus / cirrostratus" }
    { -1 "above overcast" }
}

: parse-cloud-cover ( str -- str' )
    "8/" ?head drop first3 [ CHAR: 0 - ] tri@
    [ [ f ] [ low-clouds at "low clouds are %s" sprintf ] if-zero ]
    [ [ f ] [ mid-clouds at "middle clouds are %s" sprintf ] if-zero ]
    [ [ f ] [ high-clouds at "high clouds are %s" sprintf ] if-zero ]
    tri* 3array join-words ;

: parse-inches ( str -- str' )
    dup [ CHAR: / = ] all? [ drop "unknown" ] [
        string>number
        [ "trace" ] [ 100 /f "%.2f inches" sprintf ] if-zero
    ] if ;

: parse-1hr-precipitation ( str -- str' )
    "P" ?head drop parse-inches
    "%s precipitation in last hour" sprintf ;

: parse-6hr-precipitation ( str -- str' )
    "6" ?head drop parse-inches
    "%s precipitation in last 6 hours" sprintf ;

: parse-24hr-precipitation ( str -- str' )
    "7" ?head drop parse-inches
    "%s precipitation in last 24 hours" sprintf ;

! XXX: "on the hour" instead of "00 minutes past the hour" ?

: parse-recent-time ( str -- str' )
    dup length 2 >
    [ 2 cut ":" glue ]
    [ " minutes past the hour" append ] if ;

: parse-peak-wind ( str -- str' )
    "/" split1 [ parse-wind ] [ parse-recent-time ] bi*
    "%s occuring at %s" sprintf ;

: parse-sea-level-pressure ( str -- str' )
    "SLP" ?head drop string>number 10.0 /f 1000 +
    "sea-level pressure is %s hPa" sprintf ;

: parse-lightning ( str -- str' )
    "LTG" ?head drop 2 group [ lightning at ] map join-words ;

CONSTANT: re-recent-weather R/ ((\w{2})?[BE]\d{2,4}((\w{2})?[BE]\d{2,4})?)+/

: parse-began/ended ( str -- str' )
    unclip swap
    [ CHAR: B = "began" "ended" ? ]
    [ parse-recent-time ] bi* "%s at %s" sprintf ;

: split-recent-weather ( str -- seq )
    [ dup empty? not ] [
        dup [ digit? ] find drop
        over [ digit? not ] find-from drop
        [ cut ] [ f ] if* swap
    ] produce nip ;

: (parse-recent-weather) ( str -- str' )
    dup [ digit? ] find drop 2 > [
        2 cut [ weather at " " append ] dip
    ] [ f swap ] if parse-began/ended "" append-as ;

: parse-recent-weather ( str -- str' )
    split-recent-weather
    [ (parse-recent-weather) ] map join-words ;

: parse-varying ( str -- str' )
    "V" split1 [ string>number ] bi@
    "varying between %s00 and %s00 ft" sprintf ;

: parse-from-to ( str -- str' )
    "-" split [ parse-glossary ] map " to " join ;

: parse-water-equivalent-snow ( str -- str' )
    "933" ?head drop parse-inches
    "%s water equivalent of snow on ground" sprintf ;

: parse-duration-of-sunshine ( str -- str' )
    "98" ?head drop string>number
    [ "no" ] [ "%s minutes of" sprintf ] if-zero
    "%s sunshine" sprintf ;

: parse-6hr-snowfall ( str -- str' )
    "931" ?head drop parse-inches
    "%s snowfall in last 6 hours" sprintf ;

: parse-probability ( str -- str' )
    "PROB" ?head drop string>number
    "probability of %d%%" sprintf ;

: parse-remark ( str -- str' )
    {
        { [ dup glossary key? ] [ glossary at ] }
        { [ dup R/ 1\d{4}/ matches? ] [ parse-6hr-max-temp ] }
        { [ dup R/ 2\d{4}/ matches? ] [ parse-6hr-min-temp ] }
        { [ dup R/ 4\d{8}/ matches? ] [ parse-24hr-temp ] }
        { [ dup R/ 4\/\d{3}/ matches? ] [ parse-snow-depth ] }
        { [ dup R/ 5\d{4}/ matches? ] [ parse-1hr-pressure ] }
        { [ dup R/ 6[\d\/]{4}/ matches? ] [ parse-6hr-precipitation ] }
        { [ dup R/ 7\d{4}/ matches? ] [ parse-24hr-precipitation ] }
        { [ dup R/ 8\/\d{3}/ matches? ] [ parse-cloud-cover ] }
        { [ dup R/ 931\d{3}/ matches? ] [ parse-6hr-snowfall ] }
        { [ dup R/ 933\d{3}/ matches? ] [ parse-water-equivalent-snow ] }
        { [ dup R/ 98\d{3}/ matches? ] [ parse-duration-of-sunshine ] }
        { [ dup R/ T\d{4,8}/ matches? ] [ parse-1hr-temp ] }
        { [ dup R/ \d{3}\d{2,3}\/\d{2,4}/ matches? ] [ parse-peak-wind ] }
        { [ dup R/ P\d{4}/ matches? ] [ parse-1hr-precipitation ] }
        { [ dup R/ SLP\d{3}/ matches? ] [ parse-sea-level-pressure ] }
        { [ dup R/ LTG\w+/ matches? ] [ parse-lightning ] }
        { [ dup R/ PROB\d+/ matches? ] [ parse-probability ] }
        { [ dup R/ \d{3}V\d{3}/ matches? ] [ parse-varying ] }
        { [ dup R/ [^-]+(-[^-]+)+/ matches? ] [ parse-from-to ] }
        { [ dup R/ [^\/]+(\/[^\/]+)+/ matches? ] [ ] }
        { [ dup R/ \d+.\d+/ matches? ] [ ] }
        { [ dup re-recent-weather matches? ] [ parse-recent-weather ] }
        { [ dup re-weather matches? ] [ parse-weather ] }
        { [ dup re-sky-condition matches? ] [ parse-sky-condition ] }
        [ parse-glossary ]
    } cond ;

: metar-remarks ( report seq -- report )
    [ parse-remark ] map join-words >>remarks ;

: <metar-report> ( metar -- report )
    [ metar-report new ] dip [ >>raw ] keep
    [ blank? ] split-when { "RMK" } split1
    [ metar-body ] [ metar-remarks ] bi* ;

: row. ( name quot -- )
    '[
        [ _ write ] with-cell
        [ @ [ 65 wrap-string write ] when* ] with-cell
    ] with-row ; inline

: calc-humidity ( report -- humidity/f )
    [ dew-point>> ] [ temperature>> ] bi 2dup and [
        [ " " split1 drop string>number ] bi@
        [ [ 17.625 * ] [ 243.04 + ] bi / e^ ] bi@ / 100 *
        round "%d%%" sprintf
    ] [ 2drop f ] if ;

: metar-report. ( report -- )
    standard-table-style [
        {
            [ "Station" [ station>> ] row. ]
            [ "Timestamp" [ timestamp>> ] row. ]
            [ "Wind" [ wind>> ] row. ]
            [ "Visibility" [ visibility>> ] row. ]
            [ "RVR" [ rvr>> ] row. ]
            [ "Weather" [ weather>> ] row. ]
            [ "Sky condition" [ sky-condition>> ] row. ]
            [ "Temperature" [ temperature>> ] row. ]
            [ "Dew point" [ dew-point>> ] row. ]
            [ "Altimeter" [ altimeter>> ] row. ]
            [ "Humidity" [ calc-humidity ] row. ]
            [ "Remarks" [ remarks>> ] row. ]
            [ "Raw Text" [ raw>> ] row. ]
        } cleave
    ] tabular-output nl ;

PRIVATE>

GENERIC: metar ( station -- metar )

M: station metar cccc>> metar ;

M: string metar
    "https://tgftp.nws.noaa.gov/data/observations/metar/stations/%s.TXT"
    sprintf http-get nip ;

GENERIC: metar. ( station -- )

M: station metar. cccc>> metar. ;

M: string metar.
    [ metar <metar-report> metar-report. ]
    [ drop "%s METAR not found\n" printf ] recover ;

<PRIVATE

: parse-wind-shear ( str -- str' )
    "WS" ?head drop "/" split1
    [ parse-altitude ] [ parse-wind ] bi* prepend
    "wind shear " prepend ;

CONSTANT: re-from-timestamp R/ FM\d{6}/

: parse-from-timestamp ( str -- str' )
    "FM" ?head drop parse-timestamp ;

CONSTANT: re-valid-timestamp R/ \d{4}\/\d{4}/

: parse-valid-timestamp ( str -- str' )
    "/" split1 [ "00" append parse-timestamp ] bi@ " to " glue ;

TUPLE: taf-report station timestamp valid-timestamp wind
visibility rvr weather sky-condition partials raw ;

TUPLE: taf-partial from-timestamp wind visibility rvr weather
sky-condition raw ;

: taf-body ( report str -- report )
    [ blank? ] split-when

    [ "TAF" = ] find-one drop

    [ { "AMD" "COR" "RTD" } member? ] find-one drop

    [ re-station matches? ] find-one
    [ pick station<< ] when*

    [ re-timestamp matches? ] find-one
    [ parse-timestamp pick timestamp<< ] when*

    [ re-valid-timestamp matches? ] find-one
    [ parse-valid-timestamp pick valid-timestamp<< ] when*

    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> prepend pick wind<< ] when*

    [ re-visibility matches? ] find-one
    [ parse-visibility pick visibility<< ] when*

    [ re-rvr matches? ] find-all join-words
    [ parse-rvr ] map ", " join pick rvr<<

    [ re-weather matches? ] find-all
    [ parse-weather ] map ", " join pick weather<<

    [ re-sky-condition matches? ] find-all
    [ parse-sky-condition ] map ", " join pick sky-condition<<

    drop ;

: <taf-partial> ( str -- partial )
    [ taf-partial new ] dip [ blank? ] split-when

    [ re-from-timestamp matches? ] find-one
    [ parse-from-timestamp pick from-timestamp<< ] when*

    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> prepend pick wind<< ] when*

    [ re-visibility matches? ] find-one
    [ parse-visibility pick visibility<< ] when*

    [ re-rvr matches? ] find-all join-words
    [ parse-rvr ] map ", " join pick rvr<<

    [ re-weather matches? ] find-all
    [ parse-weather ] map ", " join pick weather<<

    [ re-sky-condition matches? ] find-all
    [ parse-sky-condition ] map ", " join pick sky-condition<<

    drop ;

: taf-partials ( report seq -- report )
    [ <taf-partial> ] map >>partials ;

: <taf-report> ( taf -- report )
    [ taf-report new ] dip [ >>raw ] keep
    split-lines [ [ blank? ] trim ] map
    rest dup first "TAF" = [ rest ] when
    harvest unclip swapd taf-body swap taf-partials ;

: taf-report. ( report -- )
    [
        standard-table-style [
            {
                [ "Station" [ station>> ] row. ]
                [ "Timestamp" [ timestamp>> ] row. ]
                [ "Valid From" [ valid-timestamp>> ] row. ]
                [ "Wind" [ wind>> ] row. ]
                [ "Visibility" [ visibility>> ] row. ]
                [ "RVR" [ rvr>> ] row. ]
                [ "Weather" [ weather>> ] row. ]
                [ "Sky condition" [ sky-condition>> ] row. ]
                [ "Raw Text" [ raw>> ] row. ]
            } cleave
        ] tabular-output nl
    ] [
        partials>> [
            standard-table-style [
                {
                    [ "From" [ from-timestamp>> ] row. ]
                    [ "Wind" [ wind>> ] row. ]
                    [ "Visibility" [ visibility>> ] row. ]
                    [ "RVR" [ rvr>> ] row. ]
                    [ "Weather" [ weather>> ] row. ]
                    [ "Sky condition" [ sky-condition>> ] row. ]
                } cleave
            ] tabular-output nl
        ] each
    ] bi ;

PRIVATE>

GENERIC: taf ( station -- taf )

M: station taf cccc>> taf ;

M: string taf
    "https://tgftp.nws.noaa.gov/data/forecasts/taf/stations/%s.TXT"
    sprintf http-get nip ;

GENERIC: taf. ( station -- )

M: station taf. cccc>> taf. ;

M: string taf.
    [ taf <taf-report> taf-report. ]
    [ drop "%s TAF not found\n" printf ] recover ;

: metar-main ( -- )
    command-line get [
        [ metar print ] [ taf print ] bi nl
    ] each ;

MAIN: metar-main
