USING: combinators effects kernel math sequences splitting
strings.parser ;
IN: str-fry
: str-fry ( str -- quot ) "_" split
    [ unclip-last [ [ spin glue ] reduce-r ] 2curry ] ! not rot
    [ length 1 - 1 <effect> [ call-effect ] 2curry ] bi ;
SYNTAX: I" parse-string rest str-fry over push-all ;