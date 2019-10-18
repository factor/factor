USING: parser words compiler sequences ;

"contrib/x11/examples/lindenmayer/lindenmayer.factor" run-resource
"contrib/x11/examples/lindenmayer/viewer.factor" run-resource
"lindenmayer" words [ try-compile ] each