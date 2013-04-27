USING: assocs colors kernel tools.test ;
IN: colors.ryb

{ t } [
    {
        { T{ rgba f 1.0 0.0 0.0 } T{ ryba f 1.0 0.0 0.0 } }
        { T{ rgba f 0.0 1.0 0.0 } T{ ryba f 0.0 1.0 1.0 } }
        { T{ rgba f 0.0 0.0 1.0 } T{ ryba f 0.0 0.0 1.0 } }
        { T{ rgba f 0.0 1.0 1.0 } T{ ryba f 0.0 0.5 1.0 } }
        { T{ rgba f 1.0 0.0 1.0 } T{ ryba f 1.0 0.0 1.0 } }
        { T{ rgba f 1.0 1.0 0.0 } T{ ryba f 0.0 1.0 0.0 } }
        { T{ rgba f 0.0 0.0 0.0 } T{ ryba f 0.0 0.0 0.0 } }
        { T{ rgba f 1.0 1.0 1.0 } T{ ryba f 1.0 1.0 1.0 } }
    }
    [ [ >rgba = ] [ swap rgba>ryba = ] 2bi and ] assoc-all?
] unit-test
