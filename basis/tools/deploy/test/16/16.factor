IN: tools.deploy.test.16
USING: typed sequences math strings io ;

TYPED: typed-test ( x: integer y: string -- ) <repetition> concat print ;

: typed-main ( -- ) 3 "hi" typed-test ;

MAIN: typed-main
