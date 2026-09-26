USING: help.markup help.syntax sequences ;
IN: math.transforms.fft

HELP: fft
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Computes the forward discrete Fourier transform of a nonempty sequence of real or complex numbers. The input is not modified. Even lengths are split recursively using a radix-2 FFT; odd subproblems use a direct DFT. Power-of-two lengths take O(N log N) work, while odd lengths take O(N²) work." } ;

HELP: ifft
{ $values { "seq" sequence } { "seq'" sequence } }
{ $description "Computes the inverse discrete Fourier transform of a nonempty sequence, normalized by its length. The input is not modified. Uses the same decomposition as " { $link fft } "." } ;
