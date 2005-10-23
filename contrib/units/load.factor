USING: parser sequences words compiler ;

[
    "contrib/units/dimensioned.factor"
    "contrib/units/si-units.factor"
    "contrib/units/constants.factor"
] [ run-file ] each

! "" words [ try-compile ] each

