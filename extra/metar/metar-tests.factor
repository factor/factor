USING: metar.private tools.test ;

{ { "RAB05" "E30" "SNB20" "E55" } }
[ "RAB05E30SNB20E55" split-recent-weather ] unit-test

{ "1+1/2 statute miles" } [ "1 1/2SM" parse-visibility ] unit-test
