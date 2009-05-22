USING: arrays vectors combinators effects kernel math sequences splitting
strings.parser parser ;
IN: fries
SYMBOL: _
: str-fry ( str on -- quot ) split
    [ unclip-last [ [ spin glue ] reduce-r ] 2curry ]
    [ length 1 - 1 <effect> [ call-effect ] 2curry ] bi ;
: gen-fry ( str on -- quot ) split
    [ unclip-last [ [ spin 1array glue ] reduce-r ] 2curry ]
    [ length 1 - 1 <effect> [ call-effect ] 2curry ] bi ;

SYNTAX: i" parse-string rest "_" str-fry over push-all ;
SYNTAX: i{ \ } parse-until >array { _ } gen-fry over push-all ;
SYNTAX: iV{ \ } parse-until >vector V{ _ } gen-fry over push-all ;
