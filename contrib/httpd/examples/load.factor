IN: scratchpad
USING: words kernel parser sequences io compiler ;

"/contrib/httpd/load.factor" run-resource

{ 
    "cont-examples"
    "cont-numbers-game"
} [ "/contrib/httpd/examples/" swap ".factor" append3 run-resource ] each
