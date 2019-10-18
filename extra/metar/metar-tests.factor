USING: metar.private tools.test ;

{ { "RAB05" "E30" "SNB20" "E55" } }
[ "RAB05E30SNB20E55" split-recent-weather ] unit-test
