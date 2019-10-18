USING: noise tools.test sequences math ;

{ t } [ { 100 100 } perlin-noise-map-coords [ [ 100 <= ] all? ] all? ] unit-test
