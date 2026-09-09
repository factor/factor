# Rejected candidate29 closure

Source `29b4551bb3` passed native x86 linear-scan checked installation but failed
greedy while compiling `:SSL=>struct-slot-values`. The failure is a missing
representation on a transparent resident fragment live through GC. No timing
process was launched from this source. Raw failed records and logs are preserved.
The exact-method correction probe and source hashes are in `../../native-x86-audit/greedy-*`.
