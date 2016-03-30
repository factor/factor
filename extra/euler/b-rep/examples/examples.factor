USING: accessors assocs euler.b-rep game.models.half-edge
kernel locals math.vectors.simd.cords sequences ;
IN: euler.b-rep.examples

CONSTANT: valid-cube-b-rep
    T{ b-rep
        { faces {
            T{ face { edge  0 } { next-ring f } { base-face 0 } }
            T{ face { edge  4 } { next-ring f } { base-face 1 } }
            T{ face { edge  8 } { next-ring f } { base-face 2 } }
            T{ face { edge 12 } { next-ring f } { base-face 3 } }
            T{ face { edge 16 } { next-ring f } { base-face 4 } }
            T{ face { edge 20 } { next-ring f } { base-face 5 } }
        } }
        { edges {
            T{ b-edge { face 0 } { vertex  0 } { opposite-edge  6 } { next-edge  1 } }
            T{ b-edge { face 0 } { vertex  1 } { opposite-edge 19 } { next-edge  2 } }
            T{ b-edge { face 0 } { vertex  3 } { opposite-edge 12 } { next-edge  3 } }
            T{ b-edge { face 0 } { vertex  2 } { opposite-edge 21 } { next-edge  0 } }

            T{ b-edge { face 1 } { vertex  4 } { opposite-edge 10 } { next-edge  5 } }
            T{ b-edge { face 1 } { vertex  5 } { opposite-edge 16 } { next-edge  6 } }
            T{ b-edge { face 1 } { vertex  1 } { opposite-edge  0 } { next-edge  7 } }
            T{ b-edge { face 1 } { vertex  0 } { opposite-edge 20 } { next-edge  4 } }

            T{ b-edge { face 2 } { vertex  6 } { opposite-edge 14 } { next-edge  9 } }
            T{ b-edge { face 2 } { vertex  7 } { opposite-edge 17 } { next-edge 10 } }
            T{ b-edge { face 2 } { vertex  5 } { opposite-edge  4 } { next-edge 11 } }
            T{ b-edge { face 2 } { vertex  4 } { opposite-edge 23 } { next-edge  8 } }

            T{ b-edge { face 3 } { vertex  2 } { opposite-edge  2 } { next-edge 13 } }
            T{ b-edge { face 3 } { vertex  3 } { opposite-edge 18 } { next-edge 14 } }
            T{ b-edge { face 3 } { vertex  7 } { opposite-edge  8 } { next-edge 15 } }
            T{ b-edge { face 3 } { vertex  6 } { opposite-edge 22 } { next-edge 12 } }

            T{ b-edge { face 4 } { vertex  1 } { opposite-edge  5 } { next-edge 17 } }
            T{ b-edge { face 4 } { vertex  5 } { opposite-edge  9 } { next-edge 18 } }
            T{ b-edge { face 4 } { vertex  7 } { opposite-edge 13 } { next-edge 19 } }
            T{ b-edge { face 4 } { vertex  3 } { opposite-edge  1 } { next-edge 16 } }

            T{ b-edge { face 5 } { vertex  4 } { opposite-edge  7 } { next-edge 21 } }
            T{ b-edge { face 5 } { vertex  0 } { opposite-edge  3 } { next-edge 22 } }
            T{ b-edge { face 5 } { vertex  2 } { opposite-edge 15 } { next-edge 23 } }
            T{ b-edge { face 5 } { vertex  6 } { opposite-edge 11 } { next-edge 20 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1.0 -1.0 -1.0  0.0 } } { edge 0 } }
            T{ vertex { position double-4{ -1.0  1.0 -1.0  0.0 } } { edge 1 } }
            T{ vertex { position double-4{  1.0 -1.0 -1.0  0.0 } } { edge 3 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 2 } }
            T{ vertex { position double-4{ -1.0 -1.0  1.0  0.0 } } { edge 4 } }
            T{ vertex { position double-4{ -1.0  1.0  1.0  0.0 } } { edge 5 } }
            T{ vertex { position double-4{  1.0 -1.0  1.0  0.0 } } { edge 8 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 9 } }
        } }
    }

CONSTANT: missing-face-cube-b-rep
    T{ b-rep
        { faces {
            T{ face { edge  0 } { next-ring f } { base-face 0 } }
            T{ face { edge  4 } { next-ring f } { base-face 1 } }
            T{ face { edge  8 } { next-ring f } { base-face 2 } }
            T{ face { edge 12 } { next-ring f } { base-face 3 } }
            T{ face { edge 16 } { next-ring f } { base-face 4 } }
        } }
        { edges {
            T{ b-edge { face 0 } { vertex  0 } { opposite-edge  6 } { next-edge  1 } }
            T{ b-edge { face 0 } { vertex  1 } { opposite-edge 19 } { next-edge  2 } }
            T{ b-edge { face 0 } { vertex  3 } { opposite-edge 12 } { next-edge  3 } }
            T{ b-edge { face 0 } { vertex  2 } { opposite-edge  f } { next-edge  0 } }

            T{ b-edge { face 1 } { vertex  4 } { opposite-edge 10 } { next-edge  5 } }
            T{ b-edge { face 1 } { vertex  5 } { opposite-edge 16 } { next-edge  6 } }
            T{ b-edge { face 1 } { vertex  1 } { opposite-edge  0 } { next-edge  7 } }
            T{ b-edge { face 1 } { vertex  0 } { opposite-edge  f } { next-edge  4 } }

            T{ b-edge { face 2 } { vertex  6 } { opposite-edge 14 } { next-edge  9 } }
            T{ b-edge { face 2 } { vertex  7 } { opposite-edge 17 } { next-edge 10 } }
            T{ b-edge { face 2 } { vertex  5 } { opposite-edge  4 } { next-edge 11 } }
            T{ b-edge { face 2 } { vertex  4 } { opposite-edge  f } { next-edge  8 } }

            T{ b-edge { face 3 } { vertex  2 } { opposite-edge  2 } { next-edge 13 } }
            T{ b-edge { face 3 } { vertex  3 } { opposite-edge  f } { next-edge 14 } }
            T{ b-edge { face 3 } { vertex  7 } { opposite-edge  8 } { next-edge 15 } }
            T{ b-edge { face 3 } { vertex  6 } { opposite-edge 18 } { next-edge 12 } }

            T{ b-edge { face 4 } { vertex  1 } { opposite-edge  5 } { next-edge 17 } }
            T{ b-edge { face 4 } { vertex  5 } { opposite-edge  9 } { next-edge 18 } }
            T{ b-edge { face 4 } { vertex  7 } { opposite-edge 13 } { next-edge 19 } }
            T{ b-edge { face 4 } { vertex  3 } { opposite-edge  1 } { next-edge 16 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1.0 -1.0 -1.0  0.0 } } { edge 0 } }
            T{ vertex { position double-4{ -1.0  1.0 -1.0  0.0 } } { edge 1 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 3 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 2 } }
            T{ vertex { position double-4{ -1.0 -1.0  1.0  0.0 } } { edge 4 } }
            T{ vertex { position double-4{ -1.0  1.0  1.0  0.0 } } { edge 5 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 8 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 9 } }
        } }
    }

CONSTANT: non-quad-face-cube-b-rep
    T{ b-rep
        { faces {
            T{ face { edge  0 } { next-ring f } { base-face 0 } }
            T{ face { edge  4 } { next-ring f } { base-face 1 } }
            T{ face { edge  8 } { next-ring f } { base-face 2 } }
            T{ face { edge 12 } { next-ring f } { base-face 3 } }
            T{ face { edge 18 } { next-ring f } { base-face 4 } }
        } }
        { edges {
            T{ b-edge { face 0 } { vertex  0 } { opposite-edge  6 } { next-edge  1 } }
            T{ b-edge { face 0 } { vertex  1 } { opposite-edge 19 } { next-edge  2 } }
            T{ b-edge { face 0 } { vertex  3 } { opposite-edge 12 } { next-edge  3 } }
            T{ b-edge { face 0 } { vertex  2 } { opposite-edge 19 } { next-edge  0 } }

            T{ b-edge { face 1 } { vertex  4 } { opposite-edge 10 } { next-edge  5 } }
            T{ b-edge { face 1 } { vertex  5 } { opposite-edge 16 } { next-edge  6 } }
            T{ b-edge { face 1 } { vertex  1 } { opposite-edge  0 } { next-edge  7 } }
            T{ b-edge { face 1 } { vertex  0 } { opposite-edge 18 } { next-edge  4 } }

            T{ b-edge { face 2 } { vertex  6 } { opposite-edge 14 } { next-edge  9 } }
            T{ b-edge { face 2 } { vertex  7 } { opposite-edge 17 } { next-edge 10 } }
            T{ b-edge { face 2 } { vertex  5 } { opposite-edge  4 } { next-edge 11 } }
            T{ b-edge { face 2 } { vertex  4 } { opposite-edge 21 } { next-edge  8 } }

            T{ b-edge { face 3 } { vertex  2 } { opposite-edge  2 } { next-edge 13 } }
            T{ b-edge { face 3 } { vertex  3 } { opposite-edge 20 } { next-edge 16 } }
            T{ b-edge { face 3 } { vertex  7 } { opposite-edge  8 } { next-edge 15 } }
            T{ b-edge { face 3 } { vertex  6 } { opposite-edge 18 } { next-edge 12 } }
            T{ b-edge { face 3 } { vertex  1 } { opposite-edge  5 } { next-edge 17 } }
            T{ b-edge { face 3 } { vertex  5 } { opposite-edge  9 } { next-edge 14 } }

            T{ b-edge { face 4 } { vertex  4 } { opposite-edge  7 } { next-edge 19 } }
            T{ b-edge { face 4 } { vertex  0 } { opposite-edge  3 } { next-edge 20 } }
            T{ b-edge { face 4 } { vertex  2 } { opposite-edge 15 } { next-edge 21 } }
            T{ b-edge { face 4 } { vertex  6 } { opposite-edge 11 } { next-edge 18 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1.0 -1.0 -1.0  0.0 } } { edge 0 } }
            T{ vertex { position double-4{ -1.0  1.0 -1.0  0.0 } } { edge 1 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 3 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 2 } }
            T{ vertex { position double-4{ -1.0 -1.0  1.0  0.0 } } { edge 4 } }
            T{ vertex { position double-4{ -1.0  1.0  1.0  0.0 } } { edge 5 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 8 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 9 } }
        } }
    }

CONSTANT: multi-ringed-face-cube-b-rep
    T{ b-rep
        { faces {
            T{ face { edge  0 } { next-ring f } { base-face 0 } }
            T{ face { edge  4 } { next-ring f } { base-face 1 } }
            T{ face { edge  8 } { next-ring f } { base-face 2 } }
            T{ face { edge 12 } { next-ring f } { base-face 3 } }
            T{ face { edge 16 } { next-ring f } { base-face 4 } }
            T{ face { edge 20 } { next-ring 6 } { base-face 5 } }
            T{ face { edge 24 } { next-ring f } { base-face 5 } }
        } }
        { edges {
            T{ b-edge { face 0 } { vertex  0 } { opposite-edge  6 } { next-edge  1 } }
            T{ b-edge { face 0 } { vertex  1 } { opposite-edge 19 } { next-edge  2 } }
            T{ b-edge { face 0 } { vertex  3 } { opposite-edge 12 } { next-edge  3 } }
            T{ b-edge { face 0 } { vertex  2 } { opposite-edge 21 } { next-edge  0 } }

            T{ b-edge { face 1 } { vertex  4 } { opposite-edge 10 } { next-edge  5 } }
            T{ b-edge { face 1 } { vertex  5 } { opposite-edge 16 } { next-edge  6 } }
            T{ b-edge { face 1 } { vertex  1 } { opposite-edge  0 } { next-edge  7 } }
            T{ b-edge { face 1 } { vertex  0 } { opposite-edge 20 } { next-edge  4 } }

            T{ b-edge { face 2 } { vertex  6 } { opposite-edge 14 } { next-edge  9 } }
            T{ b-edge { face 2 } { vertex  7 } { opposite-edge 17 } { next-edge 10 } }
            T{ b-edge { face 2 } { vertex  5 } { opposite-edge  4 } { next-edge 11 } }
            T{ b-edge { face 2 } { vertex  4 } { opposite-edge 23 } { next-edge  8 } }

            T{ b-edge { face 3 } { vertex  2 } { opposite-edge  2 } { next-edge 13 } }
            T{ b-edge { face 3 } { vertex  3 } { opposite-edge 22 } { next-edge 14 } }
            T{ b-edge { face 3 } { vertex  7 } { opposite-edge  8 } { next-edge 15 } }
            T{ b-edge { face 3 } { vertex  6 } { opposite-edge 18 } { next-edge 12 } }

            T{ b-edge { face 4 } { vertex  1 } { opposite-edge  5 } { next-edge 17 } }
            T{ b-edge { face 4 } { vertex  5 } { opposite-edge  9 } { next-edge 18 } }
            T{ b-edge { face 4 } { vertex  7 } { opposite-edge 13 } { next-edge 19 } }
            T{ b-edge { face 4 } { vertex  3 } { opposite-edge  1 } { next-edge 16 } }

            T{ b-edge { face 5 } { vertex  4 } { opposite-edge  7 } { next-edge 21 } }
            T{ b-edge { face 5 } { vertex  0 } { opposite-edge  3 } { next-edge 22 } }
            T{ b-edge { face 5 } { vertex  2 } { opposite-edge 15 } { next-edge 23 } }
            T{ b-edge { face 5 } { vertex  6 } { opposite-edge 11 } { next-edge 20 } }

            T{ b-edge { face 6 } { vertex  8 } { opposite-edge  f } { next-edge 25 } }
            T{ b-edge { face 6 } { vertex  9 } { opposite-edge  f } { next-edge 26 } }
            T{ b-edge { face 6 } { vertex 10 } { opposite-edge  f } { next-edge 27 } }
            T{ b-edge { face 6 } { vertex 11 } { opposite-edge  f } { next-edge 24 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1.0 -1.0 -1.0  0.0 } } { edge 0 } }
            T{ vertex { position double-4{ -1.0  1.0 -1.0  0.0 } } { edge 1 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 3 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0  0.0 } } { edge 2 } }
            T{ vertex { position double-4{ -1.0 -1.0  1.0  0.0 } } { edge 4 } }
            T{ vertex { position double-4{ -1.0  1.0  1.0  0.0 } } { edge 5 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 8 } }
            T{ vertex { position double-4{  1.0  1.0  1.0  0.0 } } { edge 9 } }

            T{ vertex { position double-4{ -1.0 -1.0  0.5  0.0 } } { edge 24 } }
            T{ vertex { position double-4{ -1.0 -1.0 -0.5  0.0 } } { edge 25 } }
            T{ vertex { position double-4{  1.0  1.0 -0.5  0.0 } } { edge 26 } }
            T{ vertex { position double-4{  1.0  1.0  0.5  0.0 } } { edge 27 } }
        } }
    }

CONSTANT: valid-multi-valence-b-rep
    T{ b-rep
        { edges {
            T{ b-edge { face  0 } { vertex 23 } { opposite-edge  12 } { next-edge   1 } }
            T{ b-edge { face  0 } { vertex 22 } { opposite-edge   8 } { next-edge   2 } }
            T{ b-edge { face  0 } { vertex 20 } { opposite-edge   4 } { next-edge   3 } }
            T{ b-edge { face  0 } { vertex 21 } { opposite-edge  16 } { next-edge   0 } }

            T{ b-edge { face  1 } { vertex 21 } { opposite-edge   2 } { next-edge   5 } }
            T{ b-edge { face  1 } { vertex 20 } { opposite-edge  11 } { next-edge   6 } }
            T{ b-edge { face  1 } { vertex 16 } { opposite-edge  20 } { next-edge   7 } }
            T{ b-edge { face  1 } { vertex 17 } { opposite-edge  17 } { next-edge   4 } }

            T{ b-edge { face  2 } { vertex 20 } { opposite-edge   1 } { next-edge   9 } }
            T{ b-edge { face  2 } { vertex 22 } { opposite-edge  15 } { next-edge  10 } }
            T{ b-edge { face  2 } { vertex 18 } { opposite-edge  24 } { next-edge  11 } }
            T{ b-edge { face  2 } { vertex 16 } { opposite-edge   5 } { next-edge   8 } }

            T{ b-edge { face  3 } { vertex 22 } { opposite-edge   0 } { next-edge  13 } }
            T{ b-edge { face  3 } { vertex 23 } { opposite-edge  19 } { next-edge  14 } }
            T{ b-edge { face  3 } { vertex 19 } { opposite-edge  28 } { next-edge  15 } }
            T{ b-edge { face  3 } { vertex 18 } { opposite-edge   9 } { next-edge  12 } }

            T{ b-edge { face  4 } { vertex 23 } { opposite-edge   3 } { next-edge  17 } }
            T{ b-edge { face  4 } { vertex 21 } { opposite-edge   7 } { next-edge  18 } }
            T{ b-edge { face  4 } { vertex 17 } { opposite-edge  32 } { next-edge  19 } }
            T{ b-edge { face  4 } { vertex 19 } { opposite-edge  13 } { next-edge  16 } }

            T{ b-edge { face  5 } { vertex 17 } { opposite-edge   6 } { next-edge  21 } }
            T{ b-edge { face  5 } { vertex 16 } { opposite-edge  27 } { next-edge  22 } }
            T{ b-edge { face  5 } { vertex 0  } { opposite-edge  36 } { next-edge  23 } }
            T{ b-edge { face  5 } { vertex 1  } { opposite-edge  33 } { next-edge  20 } }

            T{ b-edge { face  6 } { vertex 16 } { opposite-edge  10 } { next-edge  25 } }
            T{ b-edge { face  6 } { vertex 18 } { opposite-edge  31 } { next-edge  26 } }
            T{ b-edge { face  6 } { vertex 2  } { opposite-edge  44 } { next-edge  27 } }
            T{ b-edge { face  6 } { vertex 0  } { opposite-edge  21 } { next-edge  24 } }

            T{ b-edge { face  7 } { vertex 18 } { opposite-edge  14 } { next-edge  29 } }
            T{ b-edge { face  7 } { vertex 19 } { opposite-edge  35 } { next-edge  30 } }
            T{ b-edge { face  7 } { vertex 3  } { opposite-edge  52 } { next-edge  31 } }
            T{ b-edge { face  7 } { vertex 2  } { opposite-edge  25 } { next-edge  28 } }

            T{ b-edge { face  8 } { vertex 19 } { opposite-edge  18 } { next-edge  33 } }
            T{ b-edge { face  8 } { vertex 17 } { opposite-edge  23 } { next-edge  34 } }
            T{ b-edge { face  8 } { vertex 1  } { opposite-edge  60 } { next-edge  35 } }
            T{ b-edge { face  8 } { vertex 3  } { opposite-edge  29 } { next-edge  32 } }

            T{ b-edge { face  9 } { vertex 1  } { opposite-edge  22 } { next-edge  37 } }
            T{ b-edge { face  9 } { vertex 0  } { opposite-edge  43 } { next-edge  38 } }
            T{ b-edge { face  9 } { vertex 8  } { opposite-edge  68 } { next-edge  39 } }
            T{ b-edge { face  9 } { vertex 9  } { opposite-edge  65 } { next-edge  36 } }

            T{ b-edge { face 10 } { vertex 0  } { opposite-edge  47 } { next-edge  41 } }
            T{ b-edge { face 10 } { vertex 10 } { opposite-edge  73 } { next-edge  42 } }
            T{ b-edge { face 10 } { vertex 24 } { opposite-edge  72 } { next-edge  43 } }
            T{ b-edge { face 10 } { vertex 8  } { opposite-edge  37 } { next-edge  40 } }

            T{ b-edge { face 11 } { vertex  0 } { opposite-edge  26 } { next-edge  45 } }
            T{ b-edge { face 11 } { vertex  2 } { opposite-edge  51 } { next-edge  46 } }
            T{ b-edge { face 11 } { vertex 12 } { opposite-edge  76 } { next-edge  47 } }
            T{ b-edge { face 11 } { vertex 10 } { opposite-edge  40 } { next-edge  44 } }

            T{ b-edge { face 12 } { vertex  2 } { opposite-edge  55 } { next-edge  49 } }
            T{ b-edge { face 12 } { vertex 14 } { opposite-edge  81 } { next-edge  50 } }
            T{ b-edge { face 12 } { vertex 26 } { opposite-edge  80 } { next-edge  51 } }
            T{ b-edge { face 12 } { vertex 12 } { opposite-edge  45 } { next-edge  48 } }

            T{ b-edge { face 13 } { vertex  2 } { opposite-edge  30 } { next-edge  53 } }
            T{ b-edge { face 13 } { vertex  3 } { opposite-edge  59 } { next-edge  54 } }
            T{ b-edge { face 13 } { vertex 15 } { opposite-edge  84 } { next-edge  55 } }
            T{ b-edge { face 13 } { vertex 14 } { opposite-edge  48 } { next-edge  52 } }

            T{ b-edge { face 14 } { vertex  3 } { opposite-edge  63 } { next-edge  57 } }
            T{ b-edge { face 14 } { vertex 13 } { opposite-edge  89 } { next-edge  58 } }
            T{ b-edge { face 14 } { vertex 27 } { opposite-edge  88 } { next-edge  59 } }
            T{ b-edge { face 14 } { vertex 15 } { opposite-edge  53 } { next-edge  56 } }

            T{ b-edge { face 15 } { vertex  3 } { opposite-edge  34 } { next-edge  61 } }
            T{ b-edge { face 15 } { vertex  1 } { opposite-edge  64 } { next-edge  62 } }
            T{ b-edge { face 15 } { vertex 11 } { opposite-edge  92 } { next-edge  63 } }
            T{ b-edge { face 15 } { vertex 13 } { opposite-edge  56 } { next-edge  60 } }

            T{ b-edge { face 16 } { vertex 11 } { opposite-edge  61 } { next-edge  65 } }
            T{ b-edge { face 16 } { vertex  1 } { opposite-edge  39 } { next-edge  66 } }
            T{ b-edge { face 16 } { vertex  9 } { opposite-edge  97 } { next-edge  67 } }
            T{ b-edge { face 16 } { vertex 25 } { opposite-edge  96 } { next-edge  64 } }

            T{ b-edge { face 17 } { vertex  9 } { opposite-edge  38 } { next-edge  69 } }
            T{ b-edge { face 17 } { vertex  8 } { opposite-edge  75 } { next-edge  70 } }
            T{ b-edge { face 17 } { vertex  4 } { opposite-edge 102 } { next-edge  71 } }
            T{ b-edge { face 17 } { vertex  5 } { opposite-edge  98 } { next-edge  68 } }

            T{ b-edge { face 18 } { vertex  8 } { opposite-edge  42 } { next-edge  73 } }
            T{ b-edge { face 18 } { vertex 24 } { opposite-edge  41 } { next-edge  74 } }
            T{ b-edge { face 18 } { vertex 10 } { opposite-edge  79 } { next-edge  75 } }
            T{ b-edge { face 18 } { vertex  4 } { opposite-edge  69 } { next-edge  72 } }

            T{ b-edge { face 19 } { vertex 10 } { opposite-edge  46 } { next-edge  77 } }
            T{ b-edge { face 19 } { vertex 12 } { opposite-edge  83 } { next-edge  78 } }
            T{ b-edge { face 19 } { vertex  6 } { opposite-edge 103 } { next-edge  79 } }
            T{ b-edge { face 19 } { vertex  4 } { opposite-edge  74 } { next-edge  76 } }

            T{ b-edge { face 20 } { vertex 12 } { opposite-edge  50 } { next-edge  81 } }
            T{ b-edge { face 20 } { vertex 26 } { opposite-edge  49 } { next-edge  82 } }
            T{ b-edge { face 20 } { vertex 14 } { opposite-edge  87 } { next-edge  83 } }
            T{ b-edge { face 20 } { vertex  6 } { opposite-edge  77 } { next-edge  80 } }

            T{ b-edge { face 21 } { vertex 14 } { opposite-edge  54 } { next-edge  85 } }
            T{ b-edge { face 21 } { vertex 15 } { opposite-edge  91 } { next-edge  86 } }
            T{ b-edge { face 21 } { vertex  7 } { opposite-edge 100 } { next-edge  87 } }
            T{ b-edge { face 21 } { vertex  6 } { opposite-edge  82 } { next-edge  84 } }

            T{ b-edge { face 22 } { vertex 15 } { opposite-edge  58 } { next-edge  89 } }
            T{ b-edge { face 22 } { vertex 27 } { opposite-edge  57 } { next-edge  90 } }
            T{ b-edge { face 22 } { vertex 13 } { opposite-edge  95 } { next-edge  91 } }
            T{ b-edge { face 22 } { vertex  7 } { opposite-edge  85 } { next-edge  88 } }

            T{ b-edge { face 23 } { vertex 13 } { opposite-edge  62 } { next-edge  93 } }
            T{ b-edge { face 23 } { vertex 11 } { opposite-edge  99 } { next-edge  94 } }
            T{ b-edge { face 23 } { vertex  5 } { opposite-edge 101 } { next-edge  95 } }
            T{ b-edge { face 23 } { vertex  7 } { opposite-edge  90 } { next-edge  92 } }

            T{ b-edge { face 24 } { vertex 11 } { opposite-edge  67 } { next-edge  97 } }
            T{ b-edge { face 24 } { vertex 25 } { opposite-edge  66 } { next-edge  98 } }
            T{ b-edge { face 24 } { vertex  9 } { opposite-edge  71 } { next-edge  99 } }
            T{ b-edge { face 24 } { vertex  5 } { opposite-edge  93 } { next-edge  96 } }

            T{ b-edge { face 25 } { vertex  6 } { opposite-edge  86 } { next-edge 101 } }
            T{ b-edge { face 25 } { vertex  7 } { opposite-edge  94 } { next-edge 102 } }
            T{ b-edge { face 25 } { vertex  5 } { opposite-edge  70 } { next-edge 103 } }
            T{ b-edge { face 25 } { vertex  4 } { opposite-edge  78 } { next-edge 100 } }
        } }
        { vertices {
            T{ vertex { position double-4{  1.0  1.0  1.0 0.0 } } { edge  37 } }
            T{ vertex { position double-4{  1.0  1.0 -1.0 0.0 } } { edge  36 } }
            T{ vertex { position double-4{  1.0 -1.0  1.0 0.0 } } { edge  52 } }
            T{ vertex { position double-4{  1.0 -1.0 -1.0 0.0 } } { edge  53 } }

            T{ vertex { position double-4{  3.0  1.0  1.0 0.0 } } { edge  70 } }
            T{ vertex { position double-4{  3.0  1.0 -1.0 0.0 } } { edge  71 } }
            T{ vertex { position double-4{  3.0 -1.0  1.0 0.0 } } { edge  87 } }
            T{ vertex { position double-4{  3.0 -1.0 -1.0 0.0 } } { edge  86 } }

            T{ vertex { position double-4{  2.0  2.0  1.0 0.0 } } { edge  38 } }
            T{ vertex { position double-4{  2.0  2.0 -1.0 0.0 } } { edge  39 } }
            T{ vertex { position double-4{  2.0  1.0  2.0 0.0 } } { edge  47 } }
            T{ vertex { position double-4{  2.0  1.0 -2.0 0.0 } } { edge  62 } }

            T{ vertex { position double-4{  2.0 -1.0  2.0 0.0 } } { edge  51 } }
            T{ vertex { position double-4{  2.0 -1.0 -2.0 0.0 } } { edge  57 } }
            T{ vertex { position double-4{  2.0 -2.0  1.0 0.0 } } { edge  55 } }
            T{ vertex { position double-4{  2.0 -2.0 -1.0 0.0 } } { edge  54 } }

            T{ vertex { position double-4{ -1.0  1.0  1.0 0.0 } } { edge   6 } }
            T{ vertex { position double-4{ -1.0  1.0 -1.0 0.0 } } { edge   7 } }
            T{ vertex { position double-4{ -1.0 -1.0  1.0 0.0 } } { edge  15 } }
            T{ vertex { position double-4{ -1.0 -1.0 -1.0 0.0 } } { edge  14 } }

            T{ vertex { position double-4{ -2.0  1.0  1.0 0.0 } } { edge   2 } }
            T{ vertex { position double-4{ -2.0  1.0 -1.0 0.0 } } { edge   3 } }
            T{ vertex { position double-4{ -2.0 -1.0  1.0 0.0 } } { edge   1 } }
            T{ vertex { position double-4{ -2.0 -1.0 -1.0 0.0 } } { edge   0 } }

            T{ vertex { position double-4{  2.0  2.0  2.0 0.0 } } { edge  42 } }
            T{ vertex { position double-4{  2.0  2.0 -2.0 0.0 } } { edge  67 } }
            T{ vertex { position double-4{  2.0 -2.0  2.0 0.0 } } { edge  50 } }
            T{ vertex { position double-4{  2.0 -2.0 -2.0 0.0 } } { edge  58 } }
        } }
        { faces {
            T{ face { edge   0 } { next-ring f } { base-face  0 } }
            T{ face { edge   4 } { next-ring f } { base-face  1 } }
            T{ face { edge   8 } { next-ring f } { base-face  2 } }
            T{ face { edge  12 } { next-ring f } { base-face  3 } }
            T{ face { edge  16 } { next-ring f } { base-face  4 } }
            T{ face { edge  20 } { next-ring f } { base-face  5 } }
            T{ face { edge  24 } { next-ring f } { base-face  6 } }
            T{ face { edge  28 } { next-ring f } { base-face  7 } }
            T{ face { edge  32 } { next-ring f } { base-face  8 } }
            T{ face { edge  36 } { next-ring f } { base-face  9 } }
            T{ face { edge  40 } { next-ring f } { base-face 10 } }
            T{ face { edge  44 } { next-ring f } { base-face 11 } }
            T{ face { edge  48 } { next-ring f } { base-face 12 } }
            T{ face { edge  52 } { next-ring f } { base-face 13 } }
            T{ face { edge  56 } { next-ring f } { base-face 14 } }
            T{ face { edge  60 } { next-ring f } { base-face 15 } }
            T{ face { edge  64 } { next-ring f } { base-face 16 } }
            T{ face { edge  68 } { next-ring f } { base-face 17 } }
            T{ face { edge  72 } { next-ring f } { base-face 18 } }
            T{ face { edge  76 } { next-ring f } { base-face 19 } }
            T{ face { edge  80 } { next-ring f } { base-face 20 } }
            T{ face { edge  84 } { next-ring f } { base-face 21 } }
            T{ face { edge  88 } { next-ring f } { base-face 22 } }
            T{ face { edge  92 } { next-ring f } { base-face 23 } }
            T{ face { edge  96 } { next-ring f } { base-face 24 } }
            T{ face { edge 100 } { next-ring f } { base-face 25 } }
        } }
    }

CONSTANT: degenerate-incomplete-face
    T{ b-rep
        { edges {
            T{ b-edge { face 0 } { vertex 0 } { opposite-edge 5 } { next-edge 1 } }
            T{ b-edge { face 0 } { vertex 1 } { opposite-edge 4 } { next-edge 2 } }
            T{ b-edge { face 0 } { vertex 2 } { opposite-edge 3 } { next-edge 3 } }
            T{ b-edge { face 0 } { vertex 3 } { opposite-edge 2 } { next-edge 4 } }
            T{ b-edge { face 0 } { vertex 2 } { opposite-edge 1 } { next-edge 5 } }
            T{ b-edge { face 0 } { vertex 1 } { opposite-edge 0 } { next-edge 0 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1 -1 0 0 } } { edge 0 } }
            T{ vertex { position double-4{  1 -1 0 0 } } { edge 1 } }
            T{ vertex { position double-4{  1  1 0 0 } } { edge 2 } }
            T{ vertex { position double-4{ -1  1 0 0 } } { edge 3 } }
        } }
        { faces {
            T{ face { edge 0 } { next-ring f } { base-face 0 } }
        } }
    }

CONSTANT: partially-degenerate-second-face
    T{ b-rep
        { edges {
            T{ b-edge { face 0 } { vertex 0 } { opposite-edge 6 } { next-edge 1 } }
            T{ b-edge { face 0 } { vertex 1 } { opposite-edge 5 } { next-edge 2 } }
            T{ b-edge { face 0 } { vertex 2 } { opposite-edge 4 } { next-edge 3 } }
            T{ b-edge { face 0 } { vertex 3 } { opposite-edge 9 } { next-edge 0 } }

            T{ b-edge { face 1 } { vertex 3 } { opposite-edge 2 } { next-edge 5 } }
            T{ b-edge { face 1 } { vertex 2 } { opposite-edge 1 } { next-edge 6 } }
            T{ b-edge { face 1 } { vertex 1 } { opposite-edge 0 } { next-edge 7 } }
            T{ b-edge { face 1 } { vertex 0 } { opposite-edge 8 } { next-edge 8 } }
            T{ b-edge { face 1 } { vertex 4 } { opposite-edge 7 } { next-edge 9 } }
            T{ b-edge { face 1 } { vertex 0 } { opposite-edge 3 } { next-edge 4 } }
        } }
        { vertices {
            T{ vertex { position double-4{ -1 -1 0 0 } } { edge 0 } }
            T{ vertex { position double-4{  1 -1 0 0 } } { edge 1 } }
            T{ vertex { position double-4{  1  1 0 0 } } { edge 2 } }
            T{ vertex { position double-4{ -1  1 0 0 } } { edge 3 } }
            T{ vertex { position double-4{ -2 -2 0 0 } } { edge 8 } }
        } }
        { faces {
            T{ face { edge 0 } { next-ring f } { base-face 0 } }
            T{ face { edge 4 } { next-ring f } { base-face 1 } }
        } }
    }

: nth-when ( index/f seq -- elt/f )
    over [ nth ] [ 2drop f ] if ; inline

:: connect-b-rep ( b-rep -- )
    b-rep faces>> [
        [ b-rep edges>> nth-when ] change-edge
        [ b-rep faces>> nth-when ] change-next-ring
        [ b-rep faces>> nth-when ] change-base-face
        drop
    ] each

    b-rep vertices>> [
        [ b-rep edges>> nth-when ] change-edge
        drop
    ] each

    b-rep edges>> [
        [ b-rep faces>> nth-when ] change-face
        [ b-rep vertices>> nth-when ] change-vertex
        [ b-rep edges>> nth-when ] change-opposite-edge
        [ b-rep edges>> nth-when ] change-next-edge
        drop
    ] each ;

:: disconnect-b-rep ( b-rep -- )
    b-rep faces>> >index-hash :> face-indices
    b-rep edges>> >index-hash :> edge-indices
    b-rep vertices>> >index-hash :> vertex-indices

    b-rep faces>> [
        [ edge-indices at ] change-edge
        [ face-indices at ] change-next-ring
        [ face-indices at ] change-base-face
        drop
    ] each

    b-rep vertices>> [
        [ edge-indices at ] change-edge
        drop
    ] each

    b-rep edges>> [
        [ face-indices at ] change-face
        [ vertex-indices at ] change-vertex
        [ edge-indices at ] change-opposite-edge
        [ edge-indices at ] change-next-edge
        drop
    ] each ;

valid-cube-b-rep connect-b-rep
missing-face-cube-b-rep connect-b-rep
non-quad-face-cube-b-rep connect-b-rep
multi-ringed-face-cube-b-rep connect-b-rep
valid-multi-valence-b-rep connect-b-rep
degenerate-incomplete-face connect-b-rep
partially-degenerate-second-face connect-b-rep
