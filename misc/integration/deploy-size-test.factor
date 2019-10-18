USING: tools.deploy sequences io.files io.launcher io
kernel concurrency prettyprint ;

"." resource-path cd

"deploy-log" make-directory

{
    "automata.ui"
    "boids.ui"
    "bunny"
    "color-picker"
    "gesture-logger"
    "golden-section"
    "hello-world"
    "hello-ui"
    "lsys.ui"
    "maze"
    "nehe"
    "tetris"
    "catalyst-talk"
} [
    dup
    "deploy-log/" over append <file-writer>
    [ deploy ] with-stream
    dup file-length 1024 /f
    2array
] parallel-map .
