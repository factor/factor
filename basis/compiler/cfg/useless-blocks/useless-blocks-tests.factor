IN: compiler.cfg.useless-blocks.tests
USING: fry kernel sequences compiler.cfg.useless-blocks compiler.cfg.checker
compiler.cfg.debugger compiler.cfg.predecessors tools.test ;

{
    [ [ drop 1 ] when ]
    [ [ drop 1 ] unless ]
} [
    [ [ ] ] dip
    '[ _ test-cfg first compute-predecessors delete-useless-blocks check-cfg ] unit-test
] each