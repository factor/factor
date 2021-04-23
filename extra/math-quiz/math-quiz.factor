! Copyright (C) 2021 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators combinators.smart
continuations io kernel math math.functions math.parser
prettyprint random sequences sequences.extras splitting strings
unicode ;
IN: math-quiz

GENERIC: generate-question* ( question -- quot )
GENERIC: parse-response ( input question -- answer )
GENERIC: ask-question ( question -- )
GENERIC: >question ( obj -- question )

TUPLE: question generator generated answer response parsed-response correct? ;

TUPLE: string-question < question ;
: <string-question> ( generator -- question )
    string-question new
        swap >>generator ;

TUPLE: number-question < question ;
: <number-question> ( generator -- question )
    number-question new
        swap >>generator ;

TUPLE: multiple-choice-question < question n choices ;

: <multiple-choice-question> ( generator n -- multiple-choice-question )
    multiple-choice-question new
        swap >>n
        swap >>generator ;

TUPLE: string-response ;
TUPLE: number-response ;

M: string-response >question <string-question> ;
M: number-response >question <number-question> ;
M: object >question clone ;

M: number-question generate-question* generator>> generate-question* ;
M: string-question generate-question* generator>> generate-question* ;
M: multiple-choice-question generate-question*
    [ n>> ] [ generator>> ] bi
    '[ _ generate-question* ] replicate ;

: trim-blanks ( seq -- seq' ) " " split harvest " " join ;
: first-n-letters ( n -- seq ) <iota> [ CHAR: a + 1string ] map ;
: alphabet-zip ( seq -- zip ) [ length <iota> [ CHAR: a + 1string ] { } map-as ] keep zip ;
M: number-question parse-response drop string>number ;
M: string-question parse-response drop trim-blanks ;
M: multiple-choice-question parse-response drop trim-blanks ;

TUPLE: multiplication < number-response count n ;
TUPLE: sqrt-question < number-response random-choices ;
TUPLE: sq-question < number-response random-choices ;
TUPLE: stack-shuffler < string-response n-shufflers ;
TUPLE: state-capital-question < string-response ;

M: multiplication generate-question*
    [ count>> random ] [ n>> ] bi '[ _ random 2 + ] replicate
    '[ _ product ] ;
M: sqrt-question generate-question* random-choices>> random sq '[ _ sqrt >integer ] ;
M: sq-question generate-question* random-choices>> random '[ _ sq ] ;


CONSTANT: state-capitals H{
    { "Alabama" "Montgomery" } { "Alaska" "Juneau" } { "Arizona" "Phoenix" } { "Arkansas" "Little Rock" }
    { "California" "Sacramento" } { "Colorado" "Denver" } { "Connecticut" "Hartford" } { "Delaware" "Dover" }
    { "Florida" "Tallahassee" } { "Georgia" "Atlanta" } { "Hawaii" "Honolulu" } { "Idaho" "Boise" }
    { "Illinois" "Springfield" } { "Indiana" "Indianapolis" } { "Iowa" "Des Moines" } { "Kansas" "Topeka" }
    { "Kentucky" "Frankfort" } { "Louisiana" "Baton Rouge" } { "Maine" "Augusta" } { "Maryland" "Annapolis" }
    { "Massachusetts" "Boston" } { "Michigan" "Lansing" } { "Minnesota" "Saint Paul" } { "Mississippi" "Jackson" }
    { "Missouri" "Jefferson City" } { "Montana" "Helena" } { "Nebraska" "Lincoln" } { "Nevada" "Carson City" }
    { "New Hampshire" "Concord" } { "New Jersey" "Trenton" } { "New Mexico" "Santa Fe" } { "New York" "Albany" }
    { "North Carolina" "Raleigh" } { "North Dakota" "Bismarck" } { "Ohio" "Columbus" } { "Oklahoma" "Oklahoma City" }
    { "Oregon" "Salem" } { "Pennsylvania" "Harrisburg" } { "Rhode Island" "Providence" } { "South Carolina" "Columbia" }
    { "South Dakota" "Pierre" } { "Tennessee" "Nashville" } { "Texas" "Austin" } { "Utah" "Salt Lake City" }
    { "Vermont" "Montpelier" } { "Virginia" "Richmond" } { "Washington" "Olympia" } { "West Virginia" "Charleston" }
    { "Wisconsin" "Madison" } { "Wyoming" "Cheyenne" }
}

: state-capital ( state -- capital ) state-capitals at ;
M: state-capital-question generate-question* drop state-capitals keys random '[ _ state-capital ] ;
M: state-capital-question parse-response drop trim-blanks >title ;

CONSTANT: stack-shufflers { dup 2dup drop 2drop swap over rot -rot roll -roll 2dup pick dupd }

M: stack-shuffler generate-question*
    n-shufflers>> [ stack-shufflers random ] [ ] replicate-as
    [ inputs first-n-letters ] keep
    '[ _ _ with-datastack " " join ] ;
M: stack-shuffler parse-response drop trim-blanks ;

M: question ask-question generated>> . ;
M: string-response ask-question generated>> . ;
M: number-response ask-question generated>> . ;

M: multiple-choice-question ask-question
    [ generated>> . ] [ choices>> [ ... ] each ] bi ;

: score-question ( question input -- question/f )
    dup { f "q" } member? [
        2drop f
    ] [
        >>response
        dup [ response>> ] keep parse-response >>parsed-response
        dup [ parsed-response>> ] [ answer>> ] bi dup sequence? [ member? ] [ = ] if >>correct?
        dup answer>> dup string? [ print ] [ . ] if
    ] if ;

GENERIC: generate-question ( question -- )

ERROR: generator-needs-reponse-type generator ;
M: object generate-question
    generator-needs-reponse-type ;

M: number-response generate-question
    <number-question> generate-question ;

M: string-response generate-question
    <string-question> generate-question ;

M: question generate-question
    dup generate-question* >>generated
    dup generated>> call( -- answer ) >>answer
    drop ;

M: multiple-choice-question generate-question
    dup generate-question*
    [ random >>generated ]
    [ [ call( -- answer ) ] map alphabet-zip >>choices ] bi
    dup [ choices>> ] [ generated>> call( -- answer ) ] bi
    '[ second _ = ] find-all values keys >>answer
    drop ;

: run-one-question ( question -- question/f )
    {
        [ generate-question ]
        [ ask-question ]
        [ readln score-question nl nl ]
    } cleave ;

GENERIC: run-quiz ( obj -- questions )

M: object run-quiz ( obj -- questions )
    1array run-quiz ;

M: sequence run-quiz ( seq -- questions )
    '[ _ random >question run-one-question ] loop>array ;

GENERIC#: run-multiple-choice-quiz 1 ( obj n -- questions )

M: object run-multiple-choice-quiz [ 1array ] dip run-multiple-choice-quiz ;

M: sequence run-multiple-choice-quiz ( seq n -- questions )
    '[ _ random _ <multiple-choice-question> run-one-question ] loop>array ;

: score-quiz ( seq -- )
    [ [ correct?>> ] count ]
    [ length ] bi
    [ drop 0.0 ] [ /f ] if-zero . ;

: run-states-quiz-hard ( -- )
    T{ state-capital-question } 5 run-multiple-choice-quiz score-quiz ;

: run-shuffler-quiz ( -- )
    {
        T{ stack-shuffler { n-shufflers 4 } }
    } 5 run-multiple-choice-quiz score-quiz ;

: run-main-quiz ( -- )
    {
        T{ multiplication { count 10 } { n 10 } }
        T{ sqrt-question { random-choices 100 } }
        T{ sq-question { random-choices 100 } }
    } 5 run-multiple-choice-quiz score-quiz ;

MAIN: run-main-quiz
