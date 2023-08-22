! Copyright (C) 2010 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators combinators.short-circuit
continuations formatting io kernel math math.functions
math.order math.parser random ranges strings ;

IN: hamurabi

<PRIVATE

TUPLE: game year population births deaths stores harvest yield
plague acres eaten cost feed planted birth-factor rat-factor
total-births total-deaths ;

: <game> ( -- game )
    game new
        0 >>year
        95 >>population
        5 >>births
        0 >>deaths
        2800 >>stores
        3000 >>harvest
        3 >>yield
        f >>plague
        0 >>cost
    dup births>> '[ _ + ] change-population
    dup population>> >>total-births
    dup deaths>> >>total-deaths
    dup [ harvest>> ] [ yield>> ] bi / >>acres
    dup [ harvest>> ] [ stores>> ] bi - >>eaten ;

: #acres-available ( game -- n )
    [ stores>> ] [ cost>> ] bi /i ;

: #acres-per-person ( game -- n )
    [ acres>> ] [ population>> ] bi / ;

: #harvested ( game -- n )
    [ planted>> ] [ yield>> ] bi * ;

: #eaten ( game -- n )
    dup rat-factor>> odd?
    [ [ stores>> ] [ rat-factor>> ] bi / ] [ drop 0 ] if ;

: #stored ( game -- n )
    [ harvest>> ] [ eaten>> ] bi - ;

: #percent-died ( game -- n )
    [ total-deaths>> ] [ total-births>> ] bi / 100 * ;

: #births ( game -- n )
    {
        [ acres>> 20 * ]
        [ stores>> + ]
        [ birth-factor>> * ]
        [ population>> / ]
    } cleave 100 /i 1 + ;

: #starved ( game -- n )
    [ population>> ] [ feed>> 20 /i ] bi [-] ;

: leave-fink ( -- )
    "DUE TO THIS EXTREME MISMANAGEMENT YOU HAVE NOT ONLY" print
    "BEEN IMPEACHED AND THROWN OUT OF OFFICE BUT YOU HAVE" print
    "ALSO BEEN DECLARED 'NATIONAL FINK'!!!!" print ;

: leave-starved ( game -- game )
    dup deaths>> "YOU STARVED %d PEOPLE IN ONE YEAR!!!\n" printf
    leave-fink "exit" throw ;

: leave-nero ( -- )
    "YOUR HEAVY-HANDED PERFORMANCE SMACKS OF NERO AND IVAN IV." print
    "THE PEOPLE (REMAINING) FIND YOU AN UNPLEASANT RULER, AND" print
    "FRANKLY, HATE YOUR GUTS!" print ;

: leave-not-too-bad ( game -- game )
    "YOUR PERFORMANCE COULD HAVE BEEN SOMEWHAT BETTER, BUT" print
    "REALLY WASN'T TOO BAD AT ALL." print
    dup population>> 4/5 * floor [0..b] random
    "%d PEOPLE WOULD DEARLY LIKE TO SEE YOU ASSASSINATED\n" printf
    "BUT WE ALL HAVE OUR TRIVIAL PROBLEMS" print ;

: leave-best ( -- )
    "A FANTASTIC PERFORMANCE!!!  CHARLEMANGE, DISRAELI, AND" print
    "JEFFERSON COMBINED COULD NOT HAVE DONE BETTER!" print ;

: leave ( game -- )
    dup [ #percent-died ] [ #acres-per-person ] bi
    {
        { [ 2dup [ 33 > ] [ 7 < ] bi* or ] [ leave-fink ] }
        { [ 2dup [ 10 > ] [ 9 < ] bi* or ] [ leave-nero ] }
        { [ 2dup [ 3 > ] [ 10 < ] bi* or ] [ leave-not-too-bad ] }
        [ leave-best ]
    } cond 3drop ;

: check-number ( n -- )
    { [ f eq? ] [ 0 < ] [ fixnum? not ] } 1|| [
        "HAMURABI:  I CANNOT DO WHAT YOU WISH." print
        "GET YOURSELF ANOTHER STEWARD!!!!!" print
        "exit" throw
    ] when ;

: input ( prompt -- n/f )
    write flush readln string>number [ check-number ] keep ;

: bad-stores ( game -- )
    stores>>
    "HAMURABI:  THINK AGAIN. YOU HAVE ONLY" print
    "%d BUSHELS OF STORES. NOW THEN," printf nl ;

: bad-acres ( game -- )
    acres>>
    "HAMURABI:  THINK AGAIN. YOU ONLY OWN %d ACRES. NOW THEN,"
    printf nl ;

: bad-population ( game -- )
    population>>
    "BUT YOU HAVE ONLY %d PEOPLE TO TEND THE FIELDS. NOW THEN,"
    printf nl ;

: check-error ( game n error -- game n ? )
    {
        { "acres" [ over bad-acres t ] }
        { "stores" [ over bad-stores t ] }
        { "population" [ over bad-population t ] }
        [ drop f ]
    } case ;

: adjust-acres ( game n -- game )
    [ '[ _ + ] change-acres ]
    [ over cost>> * '[ _ - ] change-stores ] bi ;

: buy-acres ( game -- game )
    "HOW MANY ACRES DO YOU WISH TO BUY? " input
    over #acres-available dupd > "stores" and check-error
    [ drop buy-acres ] [ adjust-acres ] if ;

: sell-acres ( game -- game )
    "HOW MANY ACRES DO YOU WISH TO SELL? " input
    over acres>> dupd >= "acres" and check-error
    [ drop sell-acres ] [ neg adjust-acres ] if nl ;

: trade-land ( game -- game )
    dup cost>> "LAND IS TRADING AT %d BUSHELS PER ACRE.\n" printf
    buy-acres sell-acres ;

: feed-people ( game -- game )
    "HOW MANY BUSHELS DO YOU WISH TO FEED YOUR PEOPLE? " input
    over stores>> dupd > "stores" and check-error
    [ drop feed-people ] [
        [ >>feed ] [ '[ _ - ] change-stores ] bi
    ] if nl ;

: plant-seeds ( game -- game )
    "HOW MANY ACRES DO YOU WISH TO PLANT WITH SEED? " input {
        { [ over acres>> dupd > ] [ "acres" ] }
        { [ over stores>> 2 * dupd > ] [ "stores" ] }
        { [ over population>> 10 * dupd > ] [ "population" ] }
        [ f ]
    } cond check-error [ drop plant-seeds ] [
        [ >>planted ] [ 2/ '[ _ - ] change-stores ] bi
    ] if nl ;

: report-status ( game -- game )
    "HAMURABI:  I BEG TO REPORT TO YOU," print
    dup [ year>> ] [ deaths>> ] [ births>> ] tri
    "IN YEAR %d, %d PEOPLE STARVED, %d CAME TO THE CITY\n" printf
    dup plague>> [
        "A HORRIBLE PLAGUE STRUCK!  HALF THE PEOPLE DIED." print
    ] when
    dup population>> "POPULATION IS NOW %d.\n" printf
    dup acres>> "THE CITY NOW OWNS %d ACRES.\n" printf
    dup yield>> "YOU HARVESTED %d BUSHELS PER ACRE.\n" printf
    dup eaten>> "RATS ATE %d BUSHELS.\n" printf
    dup stores>> "YOU NOW HAVE %d BUSHELS IN STORE.\n\n" printf ;

: update-randomness ( game -- game )
    17 26 [a..b] random >>cost
    5 [1..b] random >>yield
    5 [1..b] random >>birth-factor
    5 [1..b] random >>rat-factor
    100 random 15 < >>plague ;

: update-stores ( game -- game )
    dup #harvested >>harvest
    dup #eaten >>eaten
    dup #stored '[ _ + ] change-stores ;

: update-births ( game -- game )
    dup #births
    [ >>births ]
    [ '[ _ + ] change-total-births ]
    [ '[ _ + ] change-population ] tri ;

: update-deaths ( game -- game )
    dup #starved
    [ >>deaths ]
    [ '[ _ + ] change-total-deaths ]
    [ '[ _ - ] change-population ] tri ;

: check-plague ( game -- game )
    dup plague>> [ [ 2/ ] change-population ] when ;

: check-starvation ( game -- game )
    dup [ deaths>> ] [ population>> 0.45 * ] bi >
    [ leave-starved ] when ;

: year ( game -- game )
    [ 1 + ] change-year
    report-status
    update-randomness
    trade-land
    feed-people
    plant-seeds
    update-stores
    update-births
    update-deaths
    check-plague
    check-starvation ;

: spaces ( n -- )
    CHAR: \s <string> write ;

: welcome ( -- )
    32 spaces "HAMURABI" print
    15 spaces "CREATIVE COMPUTING  MORRISTOWN, NEW JERSEY" print
    nl nl nl
    "TRY YOUR HAND AT GOVERNING ANCIENT SUMERIA" print
    "SUCCESSFULLY FOR A TEN-YEAR TERM OF OFFICE" print nl ;

: finish ( game -- )
    dup #percent-died
    "IN YOUR 10-YEAR TERM OF OFFICE, %d PERCENT OF THE\n" printf
    "POPULATION STARVED PER YEAR ON AVERAGE, I.E., A TOTAL OF" print
    dup total-deaths>> "%d PEOPLE DIED!!\n" printf
    "YOU STARTED WITH 10 ACRES PER PERSON AND ENDED WITH" print
    dup #acres-per-person "%d ACRES PER PERSON\n" printf
    nl leave nl "SO LONG FOR NOW." print ;

PRIVATE>

! FIXME: "exit" throw is used to break early, perhaps use bool?

: hamurabi ( -- )
    welcome <game> [
        10 [ year ] times finish
    ] [ 2drop ] recover ;

MAIN: hamurabi
