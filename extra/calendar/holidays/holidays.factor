! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar fry kernel locals parser
sequences vocabs words ;
IN: calendar.holidays

SINGLETONS: all world commonwealth-of-nations ;

<<
SYNTAX: HOLIDAY:
    scan-new-word
    dup "holiday" word-prop [
        dup H{ } clone "holiday" set-word-prop
    ] unless
    parse-definition ( timestamp/n -- timestamp ) define-declared ;

SYNTAX: HOLIDAY-NAME:
    [let
        scan-word "holiday" word-prop :> holidays
        scan-word :> name
        scan-object :> value
    value name holidays set-at ] ;
>>

GENERIC: holidays ( n singleton -- seq )

<PRIVATE

: (holidays) ( singleton -- seq )
    all-words [ "holiday" word-prop key? ] with filter ;

M: object holidays
    (holidays) [ execute( timestamp -- timestamp' ) ] with map ;

PRIVATE>

M: all holidays drop (holidays) ;

: holiday? ( timestamp/n singleton -- ? )
    [ holidays ] [ drop ] 2bi '[ _ same-day? ] any? ;

: holiday-assoc ( timestamp singleton -- assoc )
    (holidays) swap
    '[ [ _ swap execute( ts -- ts' ) >gmt midnight ] keep ] { } map>assoc ;

: holiday-name ( singleton word -- string/f )
    "holiday" word-prop at ;

: holiday-names ( timestamp/n singleton -- seq )
    [
        [ >gmt midnight ] dip
        [ drop ] [ holiday-assoc ] 2bi swap
        '[ drop _ same-day? ] assoc-filter values
    ] keep '[ _ swap "holiday" word-prop at ] map ;

HOLIDAY: armistice-day november 11 >>day ;
HOLIDAY-NAME: armistice-day world "Armistice Day"
