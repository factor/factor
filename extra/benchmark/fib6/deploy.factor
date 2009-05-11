USING: tools.deploy.config ;
H{
    { deploy-name "benchmark.fib6" }
    { deploy-threads? f }
    { deploy-math? f }
    { deploy-word-props? f }
    { deploy-ui? f }
    { deploy-io 1 }
    { deploy-reflection 1 }
    { "stop-after-last-window?" t }
    { deploy-unicode? f }
    { deploy-word-defs? f }
    { deploy-c-types? f }
}
