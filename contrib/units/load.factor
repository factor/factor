IN: scratchpad
USING: kernel parser sequences words compiler ;

{ 
    "dimensioned"
    "si-units"
    "constants"
} [ "contrib/units/" swap ".factor" append3 run-file ] each
