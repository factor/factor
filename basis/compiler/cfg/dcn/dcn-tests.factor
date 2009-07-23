IN: compiler.cfg.dcn.tests
USING: tools.test kernel accessors namespaces assocs math
cpu.architecture vectors sequences classes
compiler.cfg
compiler.cfg.utilities
compiler.cfg.debugger
compiler.cfg.registers
compiler.cfg.predecessors
compiler.cfg.instructions
compiler.cfg.checker
compiler.cfg.dcn
compiler.cfg.dcn.height
compiler.cfg.dcn.local
compiler.cfg.dcn.local.private
compiler.cfg.dcn.global
compiler.cfg.dcn.rewrite ;

: test-local-dcn ( insns -- insns' )
    <basic-block> swap >>instructions
    [ local-analysis ] keep
    instructions>> ;

: inserting-peeks' ( from to -- assoc )
    [ inserting-peeks ] keep untranslate-locs keys ;

: inserting-replaces' ( from to -- assoc )
    [ inserting-replaces ] keep untranslate-locs [ drop n>> 0 >= ] assoc-filter keys ;

[
    V{
        T{ ##copy f V int-regs 1 V int-regs 0 }
        T{ ##copy f V int-regs 3 V int-regs 2 }
        T{ ##copy f V int-regs 5 V int-regs 4 }
        T{ ##inc-d f -1 }
        T{ ##branch }
    }
] [
    V{
        T{ ##peek f V int-regs 0 D 0 }
        T{ ##peek f V int-regs 1 D 0 }
        T{ ##inc-d f -1 }
        T{ ##peek f V int-regs 2 D 0 }
        T{ ##peek f V int-regs 3 D 0 }
        T{ ##replace f V int-regs 2 D 0 }
        T{ ##replace f V int-regs 4 D 1 }
        T{ ##peek f V int-regs 5 D 1 }
        T{ ##replace f V int-regs 5 D 1 }
        T{ ##replace f V int-regs 6 D -1 }
        T{ ##branch }
    } test-local-dcn
] unit-test

[
    H{
        { V int-regs 1 V int-regs 0 }
        { V int-regs 3 V int-regs 2 }
        { V int-regs 5 V int-regs 4 }
    }
] [
    copies get
] unit-test

[
    H{
        { D 0 V int-regs 0 }
        { D 1 V int-regs 2 }
    }
] [ reads-locations get ] unit-test

[
    H{
        { D 0 V int-regs 6 }
        { D 2 V int-regs 4 }
    }
] [ writes-locations get ] unit-test

: test-global-dcn ( -- )
    cfg new 0 get >>entry
    compute-predecessors
    deconcatenatize
    drop ;

V{ T{ ##epilogue } T{ ##return } } 0 test-bb

[ ] [ test-global-dcn ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##inc-d f 1 }
    T{ ##peek f V int-regs 0 D 1 }
    T{ ##load-immediate f V int-regs 1 100 }
    T{ ##replace f V int-regs 1 D 2 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop

[ t ] [ 0 get kill-block? ] unit-test
[ t ] [ 2 get kill-block? ] unit-test

[ ] [ test-global-dcn ] unit-test

[ t ] [ D 0 1 get peek-in key? ] unit-test

[ f ] [ D 0 0 get peek-in key? ] unit-test

[ t ] [ D 0 1 get avail-out key? ] unit-test

[ f ] [ D 0 0 get avail-out key? ] unit-test

[ { D 0 } ] [ 0 get 1 get inserting-peeks' ] unit-test

[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test

[ { } ] [ 0 get 1 get inserting-replaces' ] unit-test

[ { D 2 } ] [ 1 get 2 get inserting-replaces' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##inc-d f -1 }
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop
2 get 3 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ t ] [ D 1 2 get peek-in key? ] unit-test
[ { D 1 } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##inc-d f 1 }
    T{ ##peek f V int-regs 0 D 1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

V{
    T{ ##peek f V int-regs 1 D 0 }
    T{ ##peek f V int-regs 2 D 1 }
    T{ ##inc-d f 1 }
    T{ ##replace f V int-regs 2 D 1 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 4 get V{ } 2sequence >>successors drop
2 get 3 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ f ] [ D 0 1 get avail-out key? ] unit-test
[ f ] [ D 1 1 get avail-out key? ] unit-test
[ t ] [ D 0 4 get peek-in key? ] unit-test
[ t ] [ D 1 4 get peek-in key? ] unit-test

[ { D 0 } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 0 get 1 get inserting-replaces' ] unit-test
[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-replaces' ] unit-test
[ { } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 3 get inserting-replaces' ] unit-test
[ { D 1 } ] [ 1 get 4 get inserting-peeks' ] unit-test
[ { } ] [ 2 get 4 get inserting-replaces' ] unit-test
[ { } ] [ 4 get 5 get inserting-peeks' ] unit-test
[ { D 1 } ] [ 4 get 5 get inserting-replaces' ] unit-test

[ t ] [ D 0 1 get peek-out key? ] unit-test
[ f ] [ D 1 1 get peek-out key? ] unit-test

[ t ] [ D 1 4 get peek-in key? ] unit-test
[ f ] [ D 1 4 get avail-in key? ] unit-test
[ t ] [ D 1 4 get avail-out key? ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##peek f V int-regs 1 D 1 }
    T{ ##inc-d f -1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f V int-regs 2 100 }
    T{ ##replace f V int-regs 2 D 1 }
    T{ ##inc-d f -1 }
    T{ ##peek f V int-regs 4 D 1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##load-immediate f V int-regs 3 100 }
    T{ ##replace f V int-regs 3 D 0 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ t ] [ D 1 4 get avail-in key? ] unit-test
[ f ] [ D 2 4 get avail-in key? ] unit-test
[ t ] [ D 1 2 get peek-in key? ] unit-test
[ f ] [ D 1 3 get peek-in key? ] unit-test

[ { D 0 } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 0 get 1 get inserting-replaces' ] unit-test
[ { D 1 } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-replaces' ] unit-test
[ { D 2 } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 3 get inserting-replaces' ] unit-test
[ { } ] [ 3 get 4 get inserting-peeks' ] unit-test
[ { } ] [ 2 get 4 get inserting-replaces' ] unit-test
[ { } ] [ 3 get 4 get inserting-replaces' ] unit-test
[ { D 0 } ] [ 4 get 5 get inserting-replaces' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##inc-d f -1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##call f drop -1 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek f V int-regs 1 D 0 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

[ t ] [ 0 get kill-block? ] unit-test
[ t ] [ 3 get kill-block? ] unit-test

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ t ] [ D 1 2 get avail-out key? ] unit-test
[ f ] [ D 1 3 get peek-out key? ] unit-test
[ f ] [ D 1 3 get avail-out key? ] unit-test
[ f ] [ D 1 4 get avail-in key? ] unit-test

[ { D 1 } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 2 get 4 get inserting-peeks' ] unit-test
[ { D 0 } ] [ 3 get 4 get inserting-peeks' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 1 test-bb

V{ T{ ##epilogue } T{ ##return } } 2 test-bb

V{ T{ ##branch } } 3 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
3 get 1 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ t ] [ D 0 1 get avail-out key? ] unit-test

[ { D 0 } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 3 get 1 get inserting-peeks' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##call f drop }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##peek f V int-regs 1 D 0 }
    T{ ##branch }
} 5 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 6 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop
5 get 6 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ { } ] [ 0 get 1 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 3 get 4 get inserting-peeks' ] unit-test
[ { D 0 } ] [ 2 get 4 get inserting-peeks' ] unit-test
[ { D 0 } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 4 get 5 get inserting-peeks' ] unit-test
[ { } ] [ 5 get 6 get inserting-peeks' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-immediate f V int-regs 1 100 }
    T{ ##replace f V int-regs 1 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek f V int-regs 2 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ { } ] [ 1 get 2 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 2 get inserting-replaces' ] unit-test
[ { D 0 } ] [ 1 get 3 get inserting-peeks' ] unit-test
[ { } ] [ 1 get 3 get inserting-replaces' ] unit-test
[ { } ] [ 2 get 4 get inserting-peeks' ] unit-test
[ { D 0 } ] [ 2 get 4 get inserting-replaces' ] unit-test
[ { } ] [ 3 get 4 get inserting-peeks' ] unit-test
[ { } ] [ 3 get 4 get inserting-replaces' ] unit-test
[ { } ] [ 4 get 5 get inserting-peeks' ] unit-test
[ { } ] [ 4 get 5 get inserting-replaces' ] unit-test

V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##branch }
} 1 test-bb

V{
    T{ ##load-immediate f V int-regs 1 100 }
    T{ ##replace f V int-regs 1 D 0 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##load-immediate f V int-regs 2 100 }
    T{ ##replace f V int-regs 2 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##branch }
} 4 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 5 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 3 get V{ } 2sequence >>successors drop
2 get 4 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop
4 get 5 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ { } ] [ 2 get 4 get inserting-replaces' ] unit-test

[ { } ] [ 3 get 4 get inserting-replaces' ] unit-test

[ { D 0 } ] [ 4 get 5 get inserting-replaces' ] unit-test

! Dead replace elimination
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##peek f V int-regs 1 D 1 }
    T{ ##replace f V int-regs 1 D 0 }
    T{ ##replace f V int-regs 0 D 1 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##inc-d f -2 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 3 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop
2 get 3 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ { } ] [ 0 get 1 get inserting-replaces' ] unit-test
[ { } ] [ 1 get 2 get inserting-replaces' ] unit-test
[ { } ] [ 2 get 3 get inserting-replaces' ] unit-test

! More dead replace elimination tests
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{    
    T{ ##peek { dst V int-regs 10 } { loc D 0 } }
    T{ ##inc-d { n -1 } }
    T{ ##inc-r { n 1 } }
    T{ ##replace { src V int-regs 10 } { loc R 0 } }
    T{ ##peek { dst V int-regs 12 } { loc R 0 } }
    T{ ##inc-r { n -1 } }
    T{ ##inc-d { n 1 } }
    T{ ##replace { src V int-regs 12 } { loc D 0 } }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 2 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ { } ] [ 1 get 2 get inserting-replaces' ] unit-test

! Check that retain stack usage works
V{
    T{ ##prologue }
    T{ ##branch }
} 0 test-bb

V{
    T{ ##peek f V int-regs 0 D 0 }
    T{ ##inc-d f -1 }
    T{ ##inc-r f 1 }
    T{ ##replace f V int-regs 0 R 0 }
    T{ ##branch }
} 1 test-bb

V{
    T{ ##call f + -1 }
    T{ ##branch }
} 2 test-bb

V{
    T{ ##peek f V int-regs 0 R 0 }
    T{ ##inc-r f -1 }
    T{ ##inc-d f 1 }
    T{ ##replace f V int-regs 0 D 0 }
    T{ ##branch }
} 3 test-bb

V{
    T{ ##epilogue }
    T{ ##return }
} 4 test-bb

0 get 1 get 1vector >>successors drop
1 get 2 get 1vector >>successors drop
2 get 3 get 1vector >>successors drop
3 get 4 get 1vector >>successors drop

[ ] [ test-global-dcn ] unit-test

[ ##replace D 0 ] [
    3 get successors>> first instructions>> first
    [ class ] [ loc>> ] bi
] unit-test

[ ##replace R 0 ] [
    1 get successors>> first instructions>> first
    [ class ] [ loc>> ] bi
] unit-test

[ ##peek R 0 ] [
    2 get successors>> first instructions>> first
    [ class ] [ loc>> ] bi
] unit-test