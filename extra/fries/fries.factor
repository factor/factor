USING: arrays vectors combinators effects kernel math sequences splitting
strings.parser parser fry sequences.extras ;
IN: fries
: str-fry ( str on -- quot ) split
    [ unclip-last [ [ spin glue ] reduce-r ] 2curry ]
    [ length 1 - 1 <effect> [ call-effect ] 2curry ] bi ;
: gen-fry ( str on -- quot ) split
    [ unclip-last [ [ spin 1array glue ] reduce-r ] 2curry ]
    [ length 1 - 1 <effect> [ call-effect ] 2curry ] bi ;

SYNTAX: i" parse-string rest "_" str-fry append! ;
SYNTAX: i{ \ } parse-until >array { _ } gen-fry append! ;
SYNTAX: iV{ \ } parse-until >vector V{ _ } gen-fry append! ;
