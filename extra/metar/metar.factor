! Copyright (C) 2013 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors arrays ascii assocs calendar calendar.format calendar.parser
classes.tuple combinators command-line continuations csv
formatting grouping http.client io io.encodings.ascii io.files
io.styles kernel locals math math.functions math.order math.parser
namespaces regexp sequences sorting sorting.human splitting strings
urls vectors wrap.strings ;

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
altimeter runway-state wind-shear sea-condition remarks trend status unparsed raw ;

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
    { "TS" "thunderstorm" }
    { "UP" "unknown precipitation" }
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
            [ dup glossary at [ nip ] when* ] if
        ] map join-words
    ] map "/" join ;

! Reports contain day/time only. Resolve against a UTC reference, including
! adjacent months, rather than assuming the local current month.
SYMBOL: report-reference-time

:: parse-timestamp-at ( str reference -- timestamp )
    str 2 head string>number :> day
    2 4 str subseq string>number :> hour
    4 6 str subseq string>number :> minute
    { -1 0 1 } [
        months reference swap time+ start-of-month
        day 1 - days time+
    ] map [ day>> day = ] filter
    [ timestamp>unix-time reference timestamp>unix-time - abs ] sort-by
    first hour hours time+ minute minutes time+ ;

: parse-timestamp ( str -- str' )
    report-reference-time get [ now-utc ] unless*
    parse-timestamp-at timestamp>rfc822 ;

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
    {
        { [ dup "VRB" = ] [ drop "variable" ] }
        { [ dup "///" = ] [ drop "unknown direction" ] }
        [ parse-compass "from %s" sprintf ]
    } cond ;

: kt>mph ( kt -- mph ) 1.15077945 * ;

: mph>kt ( mph -- kt ) 1.15077945 / ;

: (parse-speed) ( str units -- str'/f )
    [ string>number ] dip '[
        _ dup "knots" =
        [ drop dup kt>mph "%s knots (%.1f mph)" sprintf ]
        [ "%s %s" sprintf ] if
    ] [ f ] if* ;

:: parse-speed ( str units -- str'/f )
    str "P" head?
    [ str rest units (parse-speed) "more than " prepend ]
    [ str "//" = [ "unknown speed" ]
      [ str units (parse-speed) ] if ] if ;

: parse-wind ( str -- str' )
    dup "00000" head? [ drop "calm" ] [
        dup "//" subseq-of? [ 3 cut ] [ "/" split1 [ 3 cut ] unless* ] if
        [ parse-direction ] dip {
            { [ "KT" ?tail ] [ "knots" ] }
            { [ "MPS" ?tail ] [ "meters per second" ] }
            { [ "KMH" ?tail ] [ "kilometers per hour" ] }
            [ "knots" ]
        } cond [ "G" split1 ] dip '[ _ parse-speed ] bi@
        [ "%s at %s with gusts to %s " sprintf ]
        [ "%s at %s" sprintf ] if*
    ] if ;

: parse-wind-variable ( str -- str' )
    "V" split1 [ parse-compass ] bi@
    ", variable from %s to %s" sprintf ;

: parse-visibility ( str -- str' )
    dup "////" = [ drop "visibility unavailable" ] [
    "SM" ?tail [
        dup first {
            { CHAR: M [ rest "less than " ] }
            { CHAR: P [ rest "more than " ] }
            [ drop "" ]
        } case swap
            "%s%s statute miles" sprintf
    ] [
        "NDV" ?tail drop 4 cut [
            string>number {
                { [ dup zero? ] [ drop "less than 50m" ] }
                { [ dup 800 < ] [ "%dm" sprintf ] }
                { [ dup 5000 < ] [ 1000 /f "%.1fkm" sprintf ] }
                { [ dup 9999 < ] [ 1000 /f "%dkm" sprintf ] }
                [ drop "10km or more" ]
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
    ] if ] if ;

: parse-range-value ( str -- str' )
    dup "////" = [ drop "unavailable" ] [
    dup first {
        { CHAR: M [ rest string>number "less than %s" sprintf ] }
        { CHAR: P [ rest string>number "more than %s" sprintf ] }
        [ drop string>number number>string ]
    } case ] if ;

: parse-rvr ( str -- str' )
    {
        { [ "U" ?tail ] [ " with improvement" ] }
        { [ "D" ?tail ] [ " with deterioration" ] }
        { [ "N" ?tail ] [ " with no change" ] }
        [ "" ]
    } cond [
        "R" ?head drop "/" split1 "FT" ?tail [
            "V" split1 [
                [ parse-range-value ] bi@
                "varying between %s and %s" sprintf
            ] [
                parse-range-value "of %s" sprintf
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
    dup "NSW" = [ drop "no significant weather" ] [
        dup "VC" subseq-of? [ "VC" "" replace t ] [ f ] if
    [ (parse-weather) ]
        [ [ " in the vicinity" append ] when ] bi*
    ] if ;

: parse-altitude ( str -- str' )
    dup "///" = [ drop " at unknown height" ]
    [ string>number 100 * " at %s ft" sprintf ] if ;

CONSTANT: sky H{
    { "BKN" "broken" }
    { "FEW" "few" }
    { "OVC" "overcast" }
    { "SCT" "scattered" }
    { "SKC" "clear sky" }
    { "CLR" "no cloud detected below 12000 ft" }
    { "NSC" "no significant cloud" }
    { "NCD" "no cloud detected" }
    { "VV" "vertical visibility" }
    { "CB" "cumulonimbus" }
    { "CAVOK" "visibility 10km or more, no significant weather or cloud" }

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
        dup "VV" head? 2 3 ? cut 3 cut
        [ sky at ]
        [ parse-altitude ]
        [ dup "///" = [ drop " (cloud type unavailable)" ]
          [ sky at [ " (%s)" sprintf ] [ f ] if* ] if ]
        tri* 3append
    ] unless ;

: F>C ( F -- C ) 32 - 5/9 * ;

: C>F ( C -- F ) 9/5 * 32 + ;

: parse-temperature-value ( str -- temp/f )
    dup [ CHAR: / = ] all? [ drop f ] [
        "M" ?head [ string>number ] [ [ neg ] when ] bi*
        dup C>F "%d °C (%.1f °F)" sprintf
    ] if ;

: parse-temperature ( str -- temp dew-point )
    dup "//" head?
    [ 3 cut [ 2 head ] dip ] [ "/" split1 ] if
    [ parse-temperature-value ] bi@ ;

: parse-altimeter ( str -- str' )
    dup "////" tail?
    [ drop "altimeter unavailable" ] [
        unclip [ string>number ] [ CHAR: A = ] bi*
        [ 100 /f "%.2f Hg" sprintf ] [ "%s hPa" sprintf ] if
    ] if ;

CONSTANT: re-timestamp R/ \d{6}Z/
CONSTANT: re-station R/ [A-Z][A-Z0-9]{3}/
CONSTANT: re-temperature R/ (M?\d{2}|\/\/)\/(M?\d{2}|\/\/)?/
CONSTANT: re-wind R/ (VRB|\d{3}|\/\/\/)(\/P?\d+|P?\d{2,3}|\/\/)(GP?\d{2,3})?(KT|MPS|KMH)/
CONSTANT: re-wind-variable R/ \d{3}V\d{3}/
CONSTANT: re-visibility R/ ((\d+ )?[MP]?\d+(\/\d+)?SM|\d{4}([NSEW]{1,2}|NDV)?|\/\/\/\/)/
CONSTANT: re-rvr R/ R\d{2}[RLC]?\/([MP]?\d{4}(V[MP]?\d{4})?|\/\/\/\/)(FT)?[UDN]?/
CONSTANT: re-weather R/ [+-]?(VC|RE)?([A-Z]{2}){1,4}/

: weather-group? ( str -- ? )
    dup "NSW" = [ drop t ] [
        dup re-weather matches? [
            [ "+-" member? ] trim-head "VC" ?head drop
            2 group [ weather key? ] all?
        ] [ drop f ] if
    ] if ;
CONSTANT: re-sky-condition R/ ((FEW|SCT|BKN|OVC)(\d{3}|\/\/\/)(CB|TCU|\/\/\/)?|VV(\d{3}|\/\/\/)|SKC|CLR|NSC|NCD|CAVOK)/
CONSTANT: re-altimeter R/ [AQ](\d{4}|\/\/\/\/)/

: find-one ( seq quot: ( elt -- ? ) -- seq' elt/f )
    dupd find [ [ swap remove-nth ] when* ] dip ; inline

: find-all ( seq quot: ( elt -- ? ) -- seq elts )
    partition swap ; inline

: fix-visibility ( seq -- seq' )
    dup [ R/ \d+(\/\d+)?SM/ matches? ] find drop [
        dup 1 - pick ?nth [ R/ \d+/ matches? ] [ f ] if* [
            cut [ unclip-last ] [ unclip swap ] bi*
            [ " " glue 1array ] [ 3append ] bi*
        ] [ drop ] if
    ] when* ;

! Legacy runway-state groups are useful when decoding archived reports.
CONSTANT: runway-deposits H{
    { "0" "clear and dry" } { "1" "damp" } { "2" "wet or water patches" }
    { "3" "rime or frost" } { "4" "dry snow" } { "5" "wet snow" }
    { "6" "slush" } { "7" "ice" } { "8" "compacted or rolled snow" }
    { "9" "frozen ruts or ridges" } { "/" "deposit not reported" }
}

CONSTANT: runway-contamination H{
    { "1" "less than 10% covered" } { "2" "11% to 25% covered" }
    { "5" "26% to 50% covered" } { "9" "51% to 100% covered" }
    { "/" "coverage not reported" }
}

: parse-deposit-depth ( str -- str' )
    {
        { [ dup "//" = ] [ drop "depth not reported" ] }
        { [ dup "00" = ] [ drop "depth less than 1 mm" ] }
        { [ dup "91" = ] [ drop "reserved depth code 91" ] }
        { [ dup "98" = ] [ drop "depth 40 cm or more" ] }
        { [ dup "99" = ] [ drop "runway non-operational; depth not reported" ] }
        [ string>number dup 92 <
          [ "depth %s mm" sprintf ]
          [ 90 - 5 * "depth %s cm" sprintf ] if ]
    } cond ;

: parse-braking ( str -- str' )
    H{
        { "91" "braking action poor" }
        { "92" "braking action medium to poor" }
        { "93" "braking action medium" }
        { "94" "braking action medium to good" }
        { "95" "braking action good" }
        { "99" "braking action unreliable" }
        { "//" "braking conditions not reported" }
    } ?at [
        string>number dup 90 <=
        [ 100 /f "friction coefficient %.2f" sprintf ]
        [ "reserved braking code %s" sprintf ] if
    ] unless ;

: parse-runway-designator ( str -- str' )
    {
        { [ dup "88" = ] [ drop "all runways" ] }
        { [ dup "99" = ] [ drop "previous runway report repeated" ] }
        { [ dup string>number [ 50 > ] [ f ] if* ]
          [ string>number 50 - "runway %02dR" sprintf ] }
        [ "runway %s" sprintf ]
    } cond ;

:: parse-runway-state ( str -- str' )
    str "R" ?head drop :> code
    ! A modern designator contains a slash at position 2 or 3; a legacy
    ! report can contain slashes inside its six-character condition code.
    str "R" head?
    [ code "/" split1 ] [ code 2 cut ] if :> ( runway state )
    runway parse-runway-designator
    state "CLRD" head? [
        state 4 tail parse-braking "%s cleared; %s" sprintf
    ] [
        0 1 state subseq runway-deposits at
        1 2 state subseq dup runway-contamination at
        [ nip ] [ "reserved coverage code " prepend ] if*
        2 4 state subseq parse-deposit-depth
        state 4 tail parse-braking
        "%s: %s; %s; %s; %s" sprintf
    ] if ;

CONSTANT: re-runway-state R/ (R\d{2}[LCR]?\/([\d\/]{6}|CLRD[\d\/]{2})|\d{2}([\d\/]{6}|CLRD[\d\/]{2}))/
CONSTANT: re-wind-shear R/ (WS\d{3}\/(VRB|\d{3})\d{2,3}(G\d{2,3})?(KT|MPS|KMH)|WSALLRWY|WSR\d{2}[LCR]?)/

: parse-wind-shear ( str -- str' )
    {
        { [ dup "WSALLRWY" = ] [ drop "wind shear on all runways" ] }
        { [ dup "WSR" head? ] [ 3 tail "wind shear on runway %s" sprintf ] }
        [ "WS" ?head drop "/" split1
          [ parse-altitude ] [ parse-wind ] bi* swap append
          "wind shear " prepend ]
    } cond ;

CONSTANT: sea-states H{
    { "0" "calm (glassy)" } { "1" "calm (rippled)" }
    { "2" "smooth (wavelets)" } { "3" "slight" } { "4" "moderate" }
    { "5" "rough" } { "6" "very rough" } { "7" "high" }
    { "8" "very high" } { "9" "phenomenal" } { "/" "unavailable" }
}

:: parse-sea-condition ( str -- str' )
    str rest :> code
    code "//" head?
    [ "//" code 3 tail ] [ code "/" split1 ] if :> ( temperature condition )
    temperature parse-temperature-value [ "unavailable" ] unless*
    condition "S" head? [
        condition rest sea-states at "sea state %s" sprintf
    ] [
        condition rest dup [ CHAR: / = ] all?
        [ drop "wave height unavailable" ]
        [ string>number 10 /f "significant wave height %.1f meters" sprintf ] if
    ] if "sea-surface temperature %s; %s" sprintf ;

CONSTANT: re-sea-condition R/ W(M?\d{2}|\/\/)\/(S[\d\/]|H(\d{1,3}|\/\/\/))/

: metar-body ( report seq -- report )
    [ { "METAR" "SPECI" } member? ] find-one
    [ pick type<< ] when*

    [ re-station matches? ] find-one
    [ pick station<< ] when*

    [ re-timestamp matches? ] find-one
    [ parse-timestamp pick timestamp<< ] when*

    [ { "AUTO" "COR" } member? ] find-all
    join-words pick modifier<<

    [ "NIL" = ] find-one
    [ pick status<< ] when*

    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> swap append pick wind<< ] when*

    fix-visibility
    [ re-visibility matches? ] find-all
    [ parse-visibility ] map ", " join pick visibility<<

    [ "CAVOK" = ] find-one [
        drop "10km or more" pick visibility<<
        "no significant weather" pick weather<<
        "no significant cloud" pick sky-condition<<
    ] when*

    [ re-rvr matches? ] find-all
    [ parse-rvr ] map ", " join pick rvr<<

    [ weather-group? ] find-all dup empty?
    [ drop ] [ [ parse-weather ] map ", " join pick weather<< ] if

    [ re-sky-condition matches? ] find-all dup empty?
    [ drop ] [ [ parse-sky-condition ] map ", " join pick sky-condition<< ] if

    [ re-temperature matches? ] find-one
    [
        parse-temperature
        [ pick temperature<< ]
        [ pick dew-point<< ] bi*
    ] when*

    [ re-altimeter matches? ] find-one
    [ parse-altimeter pick altimeter<< ] when*

    [ re-runway-state matches? ] find-all
    [ parse-runway-state ] map "; " join pick runway-state<<

    [ re-wind-shear matches? ] find-all
    [ parse-wind-shear ] map ", " join pick wind-shear<<

    [ re-sea-condition matches? ] find-all
    [ parse-sea-condition ] map ", " join pick sea-condition<<

    >>unparsed ;

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
    "3-hour pressure tendency %s, change %s hPa" sprintf ;

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
    "%s occurring at %s" sprintf ;

: parse-sea-level-pressure ( str -- str' )
    "SLP" ?head drop string>number
    dup 500 < 10000 9000 ? + 10.0 /f
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

: parse-relative-humidity ( str -- str' )
    "RH/" ?head drop string>number "relative humidity %s%%" sprintf ;

: parse-seas ( str -- str' )
    "-" split [ string>number number>string ] map " to " join
    "seas %s feet" sprintf ;

: parse-variable-visibility ( str -- str' )
    "V" split1 [ "SM" append parse-visibility ] bi@
    "visibility varying between %s and %s" sprintf ;

: parse-remark ( str -- str' )
    {
        { [ dup glossary key? ] [ glossary at ] }
        { [ dup R/ RH\/\d{1,3}/ matches? ] [ parse-relative-humidity ] }
        { [ dup R/ (\d+(\/\d+)?)V(\d+(\/\d+)?)/ matches? ] [ parse-variable-visibility ] }
        { [ dup R/ 1\d{4}/ matches? ] [ parse-6hr-max-temp ] }
        { [ dup R/ 2\d{4}/ matches? ] [ parse-6hr-min-temp ] }
        { [ dup R/ 4\d{8}/ matches? ] [ parse-24hr-temp ] }
        { [ dup R/ 4\/\d{3}/ matches? ] [ parse-snow-depth ] }
        { [ dup R/ 5\d{4}/ matches? ] [ parse-1hr-pressure ] }
        { [ dup R/ 6[\d\/]{4}/ matches? ] [ parse-6hr-precipitation ] }
        { [ dup R/ 7[\d\/]{4}/ matches? ] [ parse-24hr-precipitation ] }
        { [ dup R/ 8\/[\d\/]{3}/ matches? ] [ parse-cloud-cover ] }
        { [ dup R/ 931\d{3}/ matches? ] [ parse-6hr-snowfall ] }
        { [ dup R/ 933\d{3}/ matches? ] [ parse-water-equivalent-snow ] }
        { [ dup R/ 98\d{3}/ matches? ] [ parse-duration-of-sunshine ] }
        { [ dup R/ T[01]\d{3}([01]\d{3})?/ matches? ] [ parse-1hr-temp ] }
        { [ dup R/ \d{3}\d{2,3}\/\d{2,4}/ matches? ] [ parse-peak-wind ] }
        { [ dup R/ P[\d\/]{4}/ matches? ] [ parse-1hr-precipitation ] }
        { [ dup R/ SLP\d{3}/ matches? ] [ parse-sea-level-pressure ] }
        { [ dup R/ LTG\w+/ matches? ] [ parse-lightning ] }
        { [ dup R/ PROB\d+/ matches? ] [ parse-probability ] }
        { [ dup R/ \d{3}V\d{3}/ matches? ] [ parse-varying ] }
        { [ dup R/ [^-]+(-[^-]+)+/ matches? ] [ parse-from-to ] }
        { [ dup R/ [^\/]+(\/[^\/]+)+/ matches? ] [ ] }
        { [ dup R/ \d+.\d+/ matches? ] [ ] }
        { [ dup re-recent-weather matches? ] [ parse-recent-weather ] }
        { [ dup weather-group? ] [ parse-weather ] }
        { [ dup re-sky-condition matches? ] [ parse-sky-condition ] }
        [ parse-glossary ]
    } cond ;

! Consume multi-token remarks as units so numbers are not mistaken for
! unrelated coded groups. Leave unfamiliar words intact via parse-glossary.
:: decode-remarks ( seq -- str )
    V{ } clone :> decoded
    0 :> i!
    [ i seq length < ] [
        i seq nth :> token
        i 1 + seq ?nth :> value
        token "WSHFT" = value and [
            value parse-recent-time "wind shift at %s" sprintf decoded push
            i 2 + i!
        ] [ token "CIG" = value and [
            value "V" subseq-of?
            [ value parse-varying ] [ value parse-altitude "ceiling" prepend ] if
            decoded push i 2 + i!
        ] [ token "SEAS" = value and [
            value parse-seas decoded push i 2 + i!
        ] [ token "SNINCR" = value and [
            value "/" split1
            "snow increased %s inches in the last hour; total depth %s inches" sprintf
            decoded push i 2 + i!
        ] [ token "PK" = value "WND" = and
            i 2 + seq ?nth and [
            i 2 + seq nth parse-peak-wind "peak wind " prepend decoded push
            i 3 + i!
        ] [
            token parse-remark decoded push i 1 + i!
        ] if ] if ] if ] if ] if
    ] while decoded join-words ;

: metar-remarks ( report seq -- report )
    decode-remarks >>remarks ;

DEFER: change-groups
DEFER: report-tokens
:: parse-trend-time ( str -- str' )
    report-reference-time get [ now-utc ] unless* :> reference
    reference day>> "%02d" sprintf str 2 tail append
    reference parse-timestamp-at
    dup reference < [ 1 days time+ ] when timestamp>rfc822 ;

DEFER: <taf-partial>
DEFER: report-anchor
DEFER: taf-partial.

: (<metar-report>) ( metar -- report )
    [ metar-report new ] dip [ >>raw ] keep
    report-tokens { "RMK" } split1
    [ change-groups unclip swap [ metar-body ] dip
      [ join-words <taf-partial> ] map >>trend ]
    [ metar-remarks ] bi* ;

: <metar-report> ( metar -- report )
    dup report-anchor report-reference-time [ (<metar-report>) ] with-variable ;

: row-value. ( value -- )
    [ 65 wrap-string write ] when* ;

: row. ( name quot -- )
    '[
        [ _ write ] with-cell
        [ @ row-value. ] with-cell
    ] with-row ; inline

: calc-humidity ( report -- humidity/f )
    [ dew-point>> ] [ temperature>> ] bi 2dup and [
        [ " " split1 drop string>number ] bi@
        [ [ 17.625 * ] [ 243.04 + ] bi / e^ ] bi@ / 100 *
        round "%d%%" sprintf
    ] [ 2drop f ] if ;

: metar-report. ( report -- )
    [ standard-table-style [
        {
            [ "Station" [ station>> ] row. ]
            [ "Status" [ status>> ] row. ]
            [ "Modifier" [ modifier>> ] row. ]
            [ "Timestamp" [ timestamp>> ] row. ]
            [ "Wind" [ wind>> ] row. ]
            [ "Visibility" [ visibility>> ] row. ]
            [ "RVR" [ rvr>> ] row. ]
            [ "Weather" [ weather>> ] row. ]
            [ "Sky condition" [ sky-condition>> ] row. ]
            [ "Temperature" [ temperature>> ] row. ]
            [ "Dew point" [ dew-point>> ] row. ]
            [ "Altimeter" [ altimeter>> ] row. ]
            [ "Runway state" [ runway-state>> ] row. ]
            [ "Sea condition" [ sea-condition>> ] row. ]
            [ "Wind shear" [ wind-shear>> ] row. ]
            [ "Humidity" [ calc-humidity ] row. ]
            [ "Remarks" [ remarks>> ] row. ]
            [ "Unparsed" [ unparsed>> join-words ] row. ]
            [ "Raw Text" [ raw>> ] row. ]
        } cleave
    ] tabular-output nl ]
    [ trend>> [ taf-partial. ] each ] bi ;

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

CONSTANT: re-from-timestamp R/ FM\d{6}/

: parse-from-timestamp ( str -- str' )
    "FM" ?head drop parse-timestamp ;

CONSTANT: re-valid-timestamp R/ \d{4}\/\d{4}/

: parse-valid-timestamp ( str -- str' )
    "/" split1 [ "00" append parse-timestamp ] bi@ " to " glue ;

TUPLE: taf-report station timestamp valid-timestamp modifier status wind
visibility rvr weather sky-condition wind-shear temperatures icing turbulence
remarks unparsed partials raw ;

TUPLE: taf-partial from-timestamp until-timestamp at-timestamp valid-timestamp change probability wind
visibility rvr weather sky-condition wind-shear temperatures icing turbulence
unparsed raw ;

CONSTANT: re-forecast-temperature R/ T[XN]M?\d{2}\/\d{4}Z/

: parse-forecast-temperature ( str -- str' )
    2 cut "/" split1
    [ "/" append parse-temperature drop ]
    [ "Z" ?tail drop "00" append parse-timestamp ] bi*
    [ "TX" = "maximum" "minimum" ? ] 2dip
    "%s temperature %s at %s" sprintf ;

! Military icing/turbulence retain the code as well as its decoded extent.
CONSTANT: icing-types {
    "trace or no icing" "light mixed icing" "light rime icing in cloud"
    "light clear icing in precipitation" "moderate mixed icing"
    "moderate rime icing in cloud" "moderate clear icing in precipitation"
    "severe mixed icing" "severe rime icing in cloud"
    "severe clear icing in precipitation"
}

CONSTANT: turbulence-types H{
    { "0" "no turbulence" } { "1" "light turbulence" }
    { "2" "frequent moderate turbulence in clear air" }
    { "3" "occasional moderate turbulence in clear air" }
    { "4" "occasional moderate turbulence in cloud" }
    { "5" "frequent moderate turbulence in cloud" }
    { "6" "occasional severe turbulence in clear air" }
    { "7" "frequent severe turbulence in clear air" }
    { "8" "occasional severe turbulence in cloud" }
    { "9" "frequent severe turbulence in cloud" }
    { "X" "extreme turbulence" }
}

:: parse-layer-forecast ( str -- str' )
    1 2 str subseq :> intensity
    str first CHAR: 6 =
    [ intensity string>number icing-types nth ]
    [ intensity turbulence-types at ] if
    2 5 str subseq string>number 100 *
    str 5 tail string>number 1000 *
    "%s, base %s ft, depth %s ft" sprintf ;

: forecast-conditions ( report seq -- report )
    [ re-wind matches? ] find-one
    [ parse-wind pick wind<< ] when*

    [ re-wind-variable matches? ] find-one
    [ parse-wind-variable pick wind>> swap append pick wind<< ] when*

    fix-visibility
    [ re-visibility matches? ] find-all
    [ parse-visibility ] map ", " join pick visibility<<

    [ "CAVOK" = ] find-one [
        drop "10km or more" pick visibility<<
        "no significant weather" pick weather<<
        "no significant cloud" pick sky-condition<<
    ] when*

    [ re-rvr matches? ] find-all
    [ parse-rvr ] map ", " join pick rvr<<

    [ weather-group? ] find-all dup empty?
    [ drop ] [ [ parse-weather ] map ", " join pick weather<< ] if

    [ re-sky-condition matches? ] find-all dup empty?
    [ drop ] [ [ parse-sky-condition ] map ", " join pick sky-condition<< ] if

    [ re-wind-shear matches? ] find-all
    [ parse-wind-shear ] map ", " join pick wind-shear<<

    [ re-forecast-temperature matches? ] find-all
    [ parse-forecast-temperature ] map ", " join pick temperatures<<

    [ R/ 6\d{5}/ matches? ] find-all
    [ parse-layer-forecast ] map ", " join pick icing<<

    [ R/ 5[\dX]\d{4}/ matches? ] find-all
    [ parse-layer-forecast ] map ", " join pick turbulence<<

    >>unparsed ;

: taf-body ( report str -- report )
    [ blank? ] split-when harvest
    [ "TAF" = ] find-one drop
    [ { "AMD" "COR" "RTD" } member? ] find-all
    join-words pick modifier<<
    [ { "NIL" "CNL" } member? ] find-one
    [ pick status<< ] when*
    [ re-station matches? ] find-one
    [ pick station<< ] when*
    [ re-timestamp matches? ] find-one
    [ parse-timestamp pick timestamp<< ] when*
    [ re-valid-timestamp matches? ] find-one
    [ parse-valid-timestamp pick valid-timestamp<< ] when*
    forecast-conditions ;

: <taf-partial> ( str -- partial )
    [ taf-partial new ] dip [ >>raw ] keep
    [ blank? ] split-when harvest
    [ re-from-timestamp matches? ] find-one
    [ parse-from-timestamp pick from-timestamp<<
      "FM" pick change<< ] when*
    [ R/ PROB(30|40)/ matches? ] find-one
    [ "PROB" ?head drop string>number pick probability<<
      "PROB" pick change<< ] when*
    [ { "TEMPO" "BECMG" "NOSIG" } member? ] find-one
    [ pick change<< ] when*
    [ re-valid-timestamp matches? ] find-one
    [ parse-valid-timestamp pick valid-timestamp<< ] when*
    [ R/ FM\d{4}/ matches? ] find-one
    [ parse-trend-time pick from-timestamp<< ] when*
    [ R/ TL\d{4}/ matches? ] find-one
    [ parse-trend-time pick until-timestamp<< ] when*
    [ R/ AT\d{4}/ matches? ] find-one
    [ parse-trend-time pick at-timestamp<< ] when*
    forecast-conditions ;

:: change-groups ( seq -- groups )
    V{ } clone :> indices
    seq [| token i |
        token re-from-timestamp matches?
        token { "BECMG" "NOSIG" "PROB30" "PROB40" } member? or
        token "TEMPO" = i 1 - seq ?nth
        { "PROB30" "PROB40" } member? not and or
        [ i indices push ] when
    ] each-index
    seq indices >array split-indices harvest ;

: report-tokens ( str -- seq )
    [ CHAR: = = ] trim-tail [ blank? ] split-when harvest
    ! NOAA downloads prepend a date/time line; raw ICAO reports do not.
    dup ?first [ R/ \d{4}\/\d{2}\/\d{2}/ matches? ] [ f ] if*
    [ 2 tail ] when
    join-words "WS ALL RWY" "WSALLRWY" replace
    "WS R" "WSR" replace split-words ;

: (<taf-report>) ( taf -- report )
    [ taf-report new ] dip [ >>raw ] keep
    report-tokens { "RMK" } split1
    [ change-groups unclip swap [ join-words taf-body ] dip
      [ join-words <taf-partial> ] map >>partials ]
    [ decode-remarks >>remarks ] bi* ;

:: report-anchor ( str -- timestamp )
    report-reference-time get [ now-utc ] unless* :> reference!
    str [ blank? ] split-when harvest :> tokens
    tokens ?first [ R/ \d{4}\/\d{2}\/\d{2}/ matches? ] [ f ] if* [
        tokens first "/" "-" replace
        tokens second "T" swap append append ":00Z" append
        rfc3339>timestamp reference!
    ] when
    str report-tokens [ re-timestamp matches? ] find nip
    [ reference parse-timestamp-at ] [ reference ] if* ;

: <taf-report> ( taf -- report )
    dup report-anchor report-reference-time [ (<taf-report>) ] with-variable ;

: taf-partial. ( partial -- )
    standard-table-style [
        {
            [ "Change" [ change>> ] row. ]
            [ "Probability" [ probability>> [ number>string ] [ f ] if* ] row. ]
            [ "Period" [ valid-timestamp>> ] row. ]
            [ "From" [ from-timestamp>> ] row. ]
            [ "Until" [ until-timestamp>> ] row. ]
            [ "At" [ at-timestamp>> ] row. ]
            [ "Wind" [ wind>> ] row. ]
            [ "Visibility" [ visibility>> ] row. ]
            [ "RVR" [ rvr>> ] row. ]
            [ "Weather" [ weather>> ] row. ]
            [ "Sky condition" [ sky-condition>> ] row. ]
            [ "Wind shear" [ wind-shear>> ] row. ]
            [ "Temperatures" [ temperatures>> ] row. ]
            [ "Icing" [ icing>> ] row. ]
            [ "Turbulence" [ turbulence>> ] row. ]
            [ "Unparsed" [ unparsed>> join-words ] row. ]
        } cleave
    ] tabular-output nl ;

: taf-report. ( report -- )
    [
        standard-table-style [
            {
                [ "Station" [ station>> ] row. ]
                [ "Status" [ status>> ] row. ]
                [ "Modifier" [ modifier>> ] row. ]
                [ "Timestamp" [ timestamp>> ] row. ]
                [ "Valid From" [ valid-timestamp>> ] row. ]
                [ "Wind" [ wind>> ] row. ]
                [ "Visibility" [ visibility>> ] row. ]
                [ "RVR" [ rvr>> ] row. ]
                [ "Weather" [ weather>> ] row. ]
                [ "Sky condition" [ sky-condition>> ] row. ]
                [ "Wind shear" [ wind-shear>> ] row. ]
                [ "Temperatures" [ temperatures>> ] row. ]
                [ "Icing" [ icing>> ] row. ]
                [ "Turbulence" [ turbulence>> ] row. ]
                [ "Remarks" [ remarks>> ] row. ]
                [ "Unparsed" [ unparsed>> join-words ] row. ]
                [ "Raw Text" [ raw>> ] row. ]
            } cleave
        ] tabular-output nl
    ] [
        partials>> [ taf-partial. ] each
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

: parse-metar ( str -- report ) <metar-report> ;

: parse-taf ( str -- report ) <taf-report> ;

: metar-abbreviations ( -- assoc ) glossary ;

: metar-abbreviation ( str -- meaning/f ) glossary at ;

: metar-main ( -- )
    command-line get [
        [ metar print ] [ taf print ] bi nl
    ] each ;

MAIN: metar-main
