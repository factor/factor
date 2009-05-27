USING: arrays sequences tools.test compiler.cfg.checker compiler.cfg.debugger
compiler.cfg.def-use sets kernel ;
IN: compiler.cfg.optimizer.tests

! Miscellaneous tests

[ ] [ [ 1array ] test-mr first check-mr ] unit-test
[ ] [ [ 1 2 ? ] test-mr first check-mr ] unit-test