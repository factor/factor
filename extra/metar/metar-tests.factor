USING: metar.private tools.test ;

{ { "RAB05" "E30" "SNB20" "E55" } }
[ "RAB05E30SNB20E55" split-recent-weather ] unit-test

{ "calm" } [ "00000KT" parse-wind ] unit-test
{ "calm" } [ "00000MPS" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "36005KT" parse-wind ] unit-test
{ "from N (360°) at 5 knots (5.8 mph)" } [ "360/5KT" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "36005MPS" parse-wind ] unit-test
{ "from N (360°) at 5 meters per second" } [ "360/5MPS" parse-wind ] unit-test

{ "1+1/2 statute miles" } [ "1 1/2SM" parse-visibility ] unit-test
{ "100m" } [ "0100" parse-visibility ] unit-test
{ "4.2km" } [ "4200" parse-visibility ] unit-test
{ "5km" } [ "5000" parse-visibility ] unit-test
{ "more than 10km" } [ "9999" parse-visibility ] unit-test
{ "more than 10km north" } [ "9999N" parse-visibility ] unit-test
