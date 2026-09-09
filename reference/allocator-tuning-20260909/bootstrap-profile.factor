USING: io namespaces system tools.profiler.sampling tools.profiler.sampling.private ;
100 samples-per-second set-global
"allocator-tuning-bootstrap-samples" get-global raw-profile-data set-global
"PROFILE FLAT BEGIN" print
flat profile.
"PROFILE FLAT END" print
"PROFILE LEAF BEGIN" print
0 cross-section profile.
"PROFILE LEAF END" print
0 exit
