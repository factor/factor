USING: fry.private kernel macros math sequences splitting strings.parser ;
IN: str-fry
: str-fry ( str -- quot ) "_" split
    [ length 1 - [ncurry] [ call ] append ]
    [ unclip [ [ rot glue ] reduce ] 2curry ] bi
    prefix ;
SYNTAX: I" parse-string rest str-fry over push-all ;