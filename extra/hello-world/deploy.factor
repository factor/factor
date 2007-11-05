USING: tools.deploy.config ;
H{
    { deploy-math? f }
    { deploy-word-defs? f }
    { deploy-word-props? f }
    { deploy-name "Hello world (console)" }
    { "stop-after-last-window?" t }
    { deploy-c-types? f }
    { deploy-compiler? f }
    { deploy-io 2 }
    { deploy-ui? f }
    { deploy-reflection 1 }
}
