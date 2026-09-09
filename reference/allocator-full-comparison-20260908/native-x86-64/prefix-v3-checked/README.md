# Native v3 backtracking closure

The full frozen closure passes all26 outputs with the prefix-order and bounded
spill-tail repairs. Exact working-source patch/hashes are retained in
`../../native-x86-audit/backtracking-gc-prefix-v3.*`. This run predates the
stricter ordinary-call verifier and is not final timing acceptance.
