USING: tools.deploy.app sequences io.files io.launcher io
kernel concurrency ;

"." resource-path cd

"mkdir deploy-log" run-process

{
    "automata.ui"
    "boids.ui"
    "bunny"
    "color-picker"
    "gesture-logger"
    "golden-section"
    "hello-ui"
    "lsys.ui"
    "maze"
    "nehe"
    "tetris"
    "catalyst-talk"
} [
    "deploy-log/" over append <file-writer>
    [ deploy.app ] with-stream
] parallel-each
