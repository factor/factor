USING: tools.deploy.config ;
H{
    { deploy-reflection 1 }
    { deploy-name "Hello world (console)" }
    { deploy-word-props? f }
    { "stop-after-last-window?" t }
    { deploy-c-types? f }
    { deploy-compiler? f }
    { deploy-word-defs? f }
    { deploy-io 2 }
    { deploy-ui? f }
    { deploy-math? f }
}
