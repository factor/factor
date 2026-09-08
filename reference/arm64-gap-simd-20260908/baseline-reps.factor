USING: cpu.architecture cpu.arm.64 system ;
IN: cpu.arm.64
M: arm.64 %float>integer-vector-reps { } ;
M: arm.64 %min-vector-reps { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep float-4-rep double-2-rep } ;
M: arm.64 %max-vector-reps { char-16-rep uchar-16-rep short-8-rep ushort-8-rep int-4-rep uint-4-rep float-4-rep double-2-rep } ;
