IN: temporary
USING: compiler math tools.test kernel ;

: bail-out call + ;

[ 4 ] [ [ 2 2 ] bail-out ] unit-test
