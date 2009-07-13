IN: compiler.cfg.stack-analysis.merge.tests
USING: compiler.cfg.stack-analysis.merge tools.test arrays accessors
compiler.cfg.instructions compiler.cfg.stack-analysis.state
compiler.cfg compiler.cfg.registers compiler.cfg.debugger
cpu.architecture make assocs namespaces
sequences kernel classes ;

[
    { D 0 }
    { V int-regs 0 V int-regs 1 }
] [
    <state>

    <basic-block> V{ T{ ##branch } } >>instructions dup 1 set
    <basic-block> V{ T{ ##branch } } >>instructions dup 2 set 2array

    <state> H{ { D 0 V int-regs 0 } } >>locs>vregs
    <state> H{ { D 0 V int-regs 1 } } >>locs>vregs 2array

    H{ } clone added-instructions set
    V{ } clone added-phis set
    merge-locs locs>vregs>> keys added-phis get values first
] unit-test

[
    { D 0 }
    ##peek
] [
    <state>

    <basic-block> V{ T{ ##branch } } >>instructions dup 1 set
    <basic-block> V{ T{ ##branch } } >>instructions dup 2 set 2array

    <state>
    <state> H{ { D 0 V int-regs 1 } } >>locs>vregs 2array

    H{ } clone added-instructions set
    V{ } clone added-phis set
    [ merge-locs locs>vregs>> keys ] { } make drop
    1 get added-instructions get at first class
] unit-test

[
    0 ##inc-d
] [
    <state>

    <basic-block> V{ T{ ##branch } } >>instructions dup 1 set
    <basic-block> V{ T{ ##branch } } >>instructions dup 2 set 2array

    H{ } clone added-instructions set
    V{ } clone added-phis set

    <state> -1 >>ds-height
    <state> 2array

    [ merge-ds-heights ds-height>> ] { } make drop
    1 get added-instructions get at first class
] unit-test

[
    0
    { D 0 }
    { 1 1 }
] [
    <state>

    <basic-block> V{ T{ ##branch } } >>instructions
    <basic-block> V{ T{ ##branch } } >>instructions 2array

    H{ } clone added-instructions set
    V{ } clone added-phis set
    
    [
        <state> -1 >>ds-height H{ { D 1 V int-regs 0 } } >>locs>vregs
        <state> H{ { D 0 V int-regs 1 } } >>locs>vregs 2array

        [ merge-locs [ ds-height>> ] [ locs>vregs>> keys ] bi ] { } make drop
    ] keep
    [ instructions>> length ] map
] unit-test

[
    -1
    { D -1 }
    { 1 1 }
] [
    <state>

    <basic-block> V{ T{ ##branch } } >>instructions
    <basic-block> V{ T{ ##branch } } >>instructions 2array

    H{ } clone added-instructions set
    V{ } clone added-phis set
    
    [
        <state> -1 >>ds-height H{ { D -1 V int-regs 0 } } >>locs>vregs
        <state> -1 >>ds-height H{ { D -1 V int-regs 1 } } >>locs>vregs 2array

        [ [ merge-ds-heights ] [ merge-locs ] 2bi ] { } make drop
        [ ds-height>> ] [ locs>vregs>> keys ] bi
    ] keep
    [ instructions>> length ] map
] unit-test
