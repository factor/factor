USING: functors kernel lexer sequences vocabs.parser ;
IN: pseudo-slots
FUNCTOR: make-definitions ( D -- )
D>>     DEFINES ${D}>>
>>D     DEFINES >>${D}
(>>D)   DEFINES (>>${D})

WHERE
GENERIC: (>>D) ( value object -- )
GENERIC: D>> ( object -- value )
: >>D ( object value -- object ) over (>>D) ;
;FUNCTOR

SYNTAX: PSEUDO-SLOTS: ";" parse-tokens [ make-definitions ] each ; 