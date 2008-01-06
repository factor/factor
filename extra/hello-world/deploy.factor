USING: tools.deploy.config ;
H{
    { deploy-c-types? f }
    { deploy-ui? f }
    { deploy-reflection 1 }
    { deploy-math? f }
    { deploy-word-props? f }
    { deploy-word-defs? f }
    { deploy-name "Hello world (console)" }
    { "stop-after-last-window?" t }
    { deploy-compiler? f }
    { deploy-io 2 }
}
