USING: arrays sequences tools.test compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.def-use sets kernel kernel.private fry slots.private ;
IN: compiler.cfg.optimizer.tests

! Miscellaneous tests

{
    [ 1array ]
    [ 1 2 ? ]
    [ { array } declare [ ] map ]
    [ { array } declare dup 1 slot [ 1 slot ] when ]
} [
    [ [ ] ] dip '[ _ test-mr first check-mr ] unit-test
] each
