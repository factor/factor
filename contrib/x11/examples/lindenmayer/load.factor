USING: kernel parser words compiler sequences ;

"/contrib/x11/examples/lindenmayer/lindenmayer.factor" run-resource

"lindenmayer" words [ try-compile ] each clear
