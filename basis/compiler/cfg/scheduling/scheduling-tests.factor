USING: compiler.cfg.scheduling compiler.cfg.instructions
vocabs.loader namespaces tools.test arrays kernel random
words compiler.units ;
IN: compiler.cfg.scheduling.tests

! Test split-3-ways
[
    { }
    { }
    { T{ ##test-branch } }
] [
    V{ T{ ##test-branch } }
    split-3-ways
    [ >array ] tri@
] unit-test

[
    { T{ ##inc-d } T{ ##inc-r } T{ ##callback-inputs } }
    { T{ ##add } T{ ##sub } T{ ##mul } }
    { T{ ##test-branch } }
] [
    V{
        T{ ##inc-d }
        T{ ##inc-r }
        T{ ##callback-inputs }
        T{ ##add }
        T{ ##sub }
        T{ ##mul }
        T{ ##test-branch }
    }
    split-3-ways
    [ >array ] tri@
] unit-test

[
    { }
    { T{ ##add } T{ ##sub } T{ ##mul } }
    { T{ ##dispatch } }
] [
    V{
        T{ ##add }
        T{ ##sub }
        T{ ##mul }
        T{ ##dispatch }
    }
    split-3-ways
    [ >array ] tri@
] unit-test
