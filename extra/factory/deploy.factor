USING: tools.deploy ;
V{
    { strip-globals? f }
    { strip-word-props? f }
    { strip-word-names? f }
    { strip-dictionary? f }
    { strip-debugger? f }
    { deploy-math? t }
    { deploy-compiled? t }
    { deploy-io? f }
    { deploy-ui? f }
}
