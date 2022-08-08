USING: colors colors.contrast kernel tools.test ;

{ 0.0 } [ COLOR: black relative-luminance ] unit-test
{ 1.0 } [ COLOR: white relative-luminance ] unit-test

{ 1.0 } [ COLOR: blue dup contrast-ratio ] unit-test
{ 21.0 } [ COLOR: black COLOR: white contrast-ratio ] unit-test
