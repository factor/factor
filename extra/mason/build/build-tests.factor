USING: mason.build tools.test sequences ;
IN: mason.build.tests

{ create-build-dir enter-build-dir clone-builds-factor record-id }
[ must-infer ] each
