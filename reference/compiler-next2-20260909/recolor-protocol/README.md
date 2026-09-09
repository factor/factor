# Pending recolor experiment — not executed

The user requested a stopping point before native recolor work began. These are local protocol files only: no native recolor root/image was prepared, no native gate was run, and no native timing was collected.

The proposed source is owner freeze 3a41e9713cb5abb26dd06b748d3d423b1bfed356, isolated from residency and class-info. The observed activation is copied exactly from the owner. The derived timed activation removes only the observer symbol, vector initialization and per-CFG vector push, preserving the recoloring helper call and ordinary statistic. `activation.diff` and `activation.json` record the exact change and both hashes.

If resumed, prepare the timed candidate from the untouched a7 baseline image with the timed activation before rebuilding its selected closure. Use the observed activation only in disposable correctness processes. Positive checked counters and selected helper membership must precede a paired runtime comparison. The normal source does not enable recoloring, and this protocol is not performance or native-correctness evidence.
