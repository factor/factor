USING: kernel sequences splitting strings.parser ;
IN: str-fry
: str-fry ( str -- quot ) "_" split unclip [ [ rot glue ] reduce ] 2curry ;
SYNTAX: I" parse-string rest str-fry over push-all ;