USING: tools.deploy sequences io.files io kernel ;

"." resource-path cd

"mkdir deploy-log" run-process

"factory" "deploy-log/" over append
<file-writer> [ deploy ] with-stream
