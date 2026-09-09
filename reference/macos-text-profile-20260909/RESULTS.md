# Remaining hit-test cost

Profiled 100 warm hits on 100,000-character ASCII, BMP Chinese, and mixed Latin/emoji lines. `before.jsonl` records `[label, characters, cache_lookup_ns, native_hit_ns, index_conversion_ns, full_hit_ns]`, using the median of three batches.

Cache lookup took about 10–11 microseconds per batch; index conversion took 2–29 microseconds. Native Core Text hit testing dominated: about 46–575 milliseconds per batch. These measurements support retaining native shaping and hit-test semantics; no additional production change was made from this profiling experiment. Machine load affects absolute timings.

Reproduce with `./factor -no-user-init reference/macos-text-profile-20260909/run.factor`.
