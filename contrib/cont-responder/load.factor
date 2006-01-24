IN: scratchpad
USING: words kernel parser sequences io compiler ;

"/contrib/httpd/load.factor" run-resource
"/contrib/parser-combinators/load.factor" run-resource

{ 
    "cont-examples"
    "cont-numbers-game"
    "todo"
    "todo-example"
    "eval-responder"
    "live-updater-responder"
    "cont-testing"
} [ "/contrib/cont-responder/" swap ".factor" append3 run-resource ] each
