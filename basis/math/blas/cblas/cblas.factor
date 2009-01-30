USING: alien alien.c-types alien.syntax kernel system combinators ;
IN: math.blas.cblas

<< "cblas" {
    { [ os macosx? ] [ "libblas.dylib" "cdecl" add-library ] }
    { [ os windows? ] [ "blas.dll" "cdecl" add-library ] }
    { [ os openbsd? ] [ "libcblas.so" "cdecl" add-library ] }
    { [ os freebsd? ] [ "libcblas.so" "cdecl" add-library ] }
    [ "libblas.so" "cdecl" add-library ]
} cond >>

LIBRARY: cblas

TYPEDEF: int CBLAS_ORDER
: CblasRowMajor 101 ; inline
: CblasColMajor 102 ; inline

TYPEDEF: int CBLAS_TRANSPOSE
: CblasNoTrans   111 ; inline
: CblasTrans     112 ; inline
: CblasConjTrans 113 ; inline

TYPEDEF: int CBLAS_UPLO
: CblasUpper 121 ; inline
: CblasLower 122 ; inline

TYPEDEF: int CBLAS_DIAG
: CblasNonUnit 131 ; inline
: CblasUnit    132 ; inline

TYPEDEF: int CBLAS_SIDE
: CblasLeft  141 ; inline
: CblasRight 142 ; inline

TYPEDEF: int CBLAS_INDEX

C-STRUCT: float-complex
    { "float" "real" }
    { "float" "imag" } ;
C-STRUCT: double-complex
    { "double" "real" }
    { "double" "imag" } ;

! Level 1 BLAS (scalar-vector and vector-vector)

FUNCTION: float  cblas_sdsdot
    ( int N, float    alpha, float*   X, int incX, float*   Y, int incY ) ;
FUNCTION: double cblas_dsdot
    ( int N,                 float*   X, int incX, float*   Y, int incY ) ;
FUNCTION: float  cblas_sdot
    ( int N,                 float*   X, int incX, float*   Y, int incY ) ;
FUNCTION: double cblas_ddot
    ( int N,                 double*  X, int incX, double*  Y, int incY ) ;

FUNCTION: void   cblas_cdotu_sub
    ( int N,                 void*    X, int incX, void*    Y, int incY, void*    dotu ) ;
FUNCTION: void   cblas_cdotc_sub
    ( int N,                 void*    X, int incX, void*    Y, int incY, void*    dotc ) ;

FUNCTION: void   cblas_zdotu_sub
    ( int N,                 void*    X, int incX, void*    Y, int incY, void*    dotu ) ;
FUNCTION: void   cblas_zdotc_sub
    ( int N,                 void*    X, int incX, void*    Y, int incY, void*    dotc ) ;

FUNCTION: float  cblas_snrm2
    ( int N,                 float*   X, int incX ) ;
FUNCTION: float  cblas_sasum
    ( int N,                 float*   X, int incX ) ;

FUNCTION: double cblas_dnrm2
    ( int N,                 double*  X, int incX ) ;
FUNCTION: double cblas_dasum
    ( int N,                 double*  X, int incX ) ;

FUNCTION: float  cblas_scnrm2
    ( int N,                 void*    X, int incX ) ;
FUNCTION: float  cblas_scasum
    ( int N,                 void*    X, int incX ) ;

FUNCTION: double cblas_dznrm2
    ( int N,                 void*    X, int incX ) ;
FUNCTION: double cblas_dzasum
    ( int N,                 void*    X, int incX ) ;

FUNCTION: CBLAS_INDEX cblas_isamax
    ( int N,                 float*   X, int incX ) ;
FUNCTION: CBLAS_INDEX cblas_idamax
    ( int N,                 double*  X, int incX ) ;
FUNCTION: CBLAS_INDEX cblas_icamax
    ( int N,                 void*    X, int incX ) ;
FUNCTION: CBLAS_INDEX cblas_izamax
    ( int N,                 void*    X, int incX ) ;

FUNCTION: void cblas_sswap
    ( int N,                 float*   X, int incX, float*   Y, int incY ) ;
FUNCTION: void cblas_scopy
    ( int N,                 float*   X, int incX, float*   Y, int incY ) ;
FUNCTION: void cblas_saxpy
    ( int N, float    alpha, float*   X, int incX, float*   Y, int incY ) ;

FUNCTION: void cblas_dswap
    ( int N,                 double*  X, int incX, double*  Y, int incY ) ;
FUNCTION: void cblas_dcopy
    ( int N,                 double*  X, int incX, double*  Y, int incY ) ;
FUNCTION: void cblas_daxpy
    ( int N, double   alpha, double*  X, int incX, double*  Y, int incY ) ;

FUNCTION: void cblas_cswap
    ( int N,                 void*    X, int incX, void*    Y, int incY ) ;
FUNCTION: void cblas_ccopy
    ( int N,                 void*    X, int incX, void*    Y, int incY ) ;
FUNCTION: void cblas_caxpy
    ( int N, void*    alpha, void*    X, int incX, void*    Y, int incY ) ;

FUNCTION: void cblas_zswap
    ( int N,                 void*    X, int incX, void*    Y, int incY ) ;
FUNCTION: void cblas_zcopy
    ( int N,                 void*    X, int incX, void*    Y, int incY ) ;
FUNCTION: void cblas_zaxpy
    ( int N, void*    alpha, void*    X, int incX, void*    Y, int incY ) ;

FUNCTION: void cblas_sscal
    ( int N, float    alpha, float*   X, int incX ) ;
FUNCTION: void cblas_dscal
    ( int N, double   alpha, double*  X, int incX ) ;
FUNCTION: void cblas_cscal
    ( int N, void*    alpha, void*    X, int incX ) ;
FUNCTION: void cblas_zscal
    ( int N, void*    alpha, void*    X, int incX ) ;
FUNCTION: void cblas_csscal
    ( int N, float    alpha, void*    X, int incX ) ;
FUNCTION: void cblas_zdscal
    ( int N, double   alpha, void*    X, int incX ) ;

FUNCTION: void cblas_srotg
    ( float* a, float* b, float* c, float* s ) ;
FUNCTION: void cblas_srotmg
    ( float* d1, float* d2, float* b1, float b2, float* P ) ;
FUNCTION: void cblas_srot
    ( int N, float* X, int incX, float* Y, int incY, float c, float s ) ;
FUNCTION: void cblas_srotm
    ( int N, float* X, int incX, float* Y, int incY, float* P ) ;

FUNCTION: void cblas_drotg
    ( double* a, double* b, double* c, double* s ) ;
FUNCTION: void cblas_drotmg
    ( double* d1, double* d2, double* b1, double b2, double* P ) ;
FUNCTION: void cblas_drot
    ( int N, double* X, int incX, double* Y, int incY, double c, double s ) ;
FUNCTION: void cblas_drotm
    ( int N, double* X, int incX, double* Y, int incY, double* P ) ;
 
! Level 2 BLAS (matrix-vector)

FUNCTION: void cblas_sgemv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 float alpha, float* A, int lda,
                 float* X, int incX, float beta,
                 float* Y, int incY ) ;
FUNCTION: void cblas_sgbmv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 int KL, int KU, float alpha,
                 float* A, int lda, float* X,
                 int incX, float beta, float* Y, int incY ) ;
FUNCTION: void cblas_strmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, float* A, int lda,
                 float* X, int incX ) ;
FUNCTION: void cblas_stbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, float* A, int lda,
                 float* X, int incX ) ;
FUNCTION: void cblas_stpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, float* Ap, float* X, int incX ) ;
FUNCTION: void cblas_strsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, float* A, int lda, float* X,
                 int incX ) ;
FUNCTION: void cblas_stbsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, float* A, int lda,
                 float* X, int incX ) ;
FUNCTION: void cblas_stpsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, float* Ap, float* X, int incX ) ;

FUNCTION: void cblas_dgemv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 double alpha, double* A, int lda,
                 double* X, int incX, double beta,
                 double* Y, int incY ) ;
FUNCTION: void cblas_dgbmv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 int KL, int KU, double alpha,
                 double* A, int lda, double* X,
                 int incX, double beta, double* Y, int incY ) ;
FUNCTION: void cblas_dtrmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, double* A, int lda,
                 double* X, int incX ) ;
FUNCTION: void cblas_dtbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, double* A, int lda,
                 double* X, int incX ) ;
FUNCTION: void cblas_dtpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, double* Ap, double* X, int incX ) ;
FUNCTION: void cblas_dtrsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, double* A, int lda, double* X,
                 int incX ) ;
FUNCTION: void cblas_dtbsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, double* A, int lda,
                 double* X, int incX ) ;
FUNCTION: void cblas_dtpsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, double* Ap, double* X, int incX ) ;

FUNCTION: void cblas_cgemv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 void* alpha, void* A, int lda,
                 void* X, int incX, void* beta,
                 void* Y, int incY ) ;
FUNCTION: void cblas_cgbmv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 int KL, int KU, void* alpha,
                 void* A, int lda, void* X,
                 int incX, void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_ctrmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ctbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ctpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* Ap, void* X, int incX ) ;
FUNCTION: void cblas_ctrsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* A, int lda, void* X,
                 int incX ) ;
FUNCTION: void cblas_ctbsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ctpsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* Ap, void* X, int incX ) ;

FUNCTION: void cblas_zgemv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 void* alpha, void* A, int lda,
                 void* X, int incX, void* beta,
                 void* Y, int incY ) ;
FUNCTION: void cblas_zgbmv ( CBLAS_ORDER Order,
                 CBLAS_TRANSPOSE TransA, int M, int N,
                 int KL, int KU, void* alpha,
                 void* A, int lda, void* X,
                 int incX, void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_ztrmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ztbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ztpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* Ap, void* X, int incX ) ;
FUNCTION: void cblas_ztrsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* A, int lda, void* X,
                 int incX ) ;
FUNCTION: void cblas_ztbsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, int K, void* A, int lda,
                 void* X, int incX ) ;
FUNCTION: void cblas_ztpsv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE TransA, CBLAS_DIAG Diag,
                 int N, void* Ap, void* X, int incX ) ;


FUNCTION: void cblas_ssymv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, float alpha, float* A,
                 int lda, float* X, int incX,
                 float beta, float* Y, int incY ) ;
FUNCTION: void cblas_ssbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, int K, float alpha, float* A,
                 int lda, float* X, int incX,
                 float beta, float* Y, int incY ) ;
FUNCTION: void cblas_sspmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, float alpha, float* Ap,
                 float* X, int incX,
                 float beta, float* Y, int incY ) ;
FUNCTION: void cblas_sger ( CBLAS_ORDER Order, int M, int N,
                float alpha, float* X, int incX,
                float* Y, int incY, float* A, int lda ) ;
FUNCTION: void cblas_ssyr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, float* X,
                int incX, float* A, int lda ) ;
FUNCTION: void cblas_sspr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, float* X,
                int incX, float* Ap ) ;
FUNCTION: void cblas_ssyr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, float* X,
                int incX, float* Y, int incY, float* A,
                int lda ) ;
FUNCTION: void cblas_sspr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, float* X,
                int incX, float* Y, int incY, float* A ) ;

FUNCTION: void cblas_dsymv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, double alpha, double* A,
                 int lda, double* X, int incX,
                 double beta, double* Y, int incY ) ;
FUNCTION: void cblas_dsbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, int K, double alpha, double* A,
                 int lda, double* X, int incX,
                 double beta, double* Y, int incY ) ;
FUNCTION: void cblas_dspmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, double alpha, double* Ap,
                 double* X, int incX,
                 double beta, double* Y, int incY ) ;
FUNCTION: void cblas_dger ( CBLAS_ORDER Order, int M, int N,
                double alpha, double* X, int incX,
                double* Y, int incY, double* A, int lda ) ;
FUNCTION: void cblas_dsyr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, double* X,
                int incX, double* A, int lda ) ;
FUNCTION: void cblas_dspr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, double* X,
                int incX, double* Ap ) ;
FUNCTION: void cblas_dsyr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, double* X,
                int incX, double* Y, int incY, double* A,
                int lda ) ;
FUNCTION: void cblas_dspr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, double* X,
                int incX, double* Y, int incY, double* A ) ;


FUNCTION: void cblas_chemv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, void* alpha, void* A,
                 int lda, void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_chbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, int K, void* alpha, void* A,
                 int lda, void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_chpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, void* alpha, void* Ap,
                 void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_cgeru ( CBLAS_ORDER Order, int M, int N,
                 void* alpha, void* X, int incX,
                 void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_cgerc ( CBLAS_ORDER Order, int M, int N,
                 void* alpha, void* X, int incX,
                 void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_cher ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, void* X, int incX,
                void* A, int lda ) ;
FUNCTION: void cblas_chpr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, float alpha, void* X,
                int incX, void* A ) ;
FUNCTION: void cblas_cher2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo, int N,
                void* alpha, void* X, int incX,
                void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_chpr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo, int N,
                void* alpha, void* X, int incX,
                void* Y, int incY, void* Ap ) ;

FUNCTION: void cblas_zhemv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, void* alpha, void* A,
                 int lda, void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_zhbmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, int K, void* alpha, void* A,
                 int lda, void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_zhpmv ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 int N, void* alpha, void* Ap,
                 void* X, int incX,
                 void* beta, void* Y, int incY ) ;
FUNCTION: void cblas_zgeru ( CBLAS_ORDER Order, int M, int N,
                 void* alpha, void* X, int incX,
                 void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_zgerc ( CBLAS_ORDER Order, int M, int N,
                 void* alpha, void* X, int incX,
                 void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_zher ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, void* X, int incX,
                void* A, int lda ) ;
FUNCTION: void cblas_zhpr ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                int N, double alpha, void* X,
                int incX, void* A ) ;
FUNCTION: void cblas_zher2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo, int N,
                void* alpha, void* X, int incX,
                void* Y, int incY, void* A, int lda ) ;
FUNCTION: void cblas_zhpr2 ( CBLAS_ORDER Order, CBLAS_UPLO Uplo, int N,
                void* alpha, void* X, int incX,
                void* Y, int incY, void* Ap ) ;

! Level 3 BLAS (matrix-matrix) 

FUNCTION: void cblas_sgemm ( CBLAS_ORDER Order, CBLAS_TRANSPOSE TransA,
                 CBLAS_TRANSPOSE TransB, int M, int N,
                 int K, float alpha, float* A,
                 int lda, float* B, int ldb,
                 float beta, float* C, int ldc ) ;
FUNCTION: void cblas_ssymm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 float alpha, float* A, int lda,
                 float* B, int ldb, float beta,
                 float* C, int ldc ) ;
FUNCTION: void cblas_ssyrk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 float alpha, float* A, int lda,
                 float beta, float* C, int ldc ) ;
FUNCTION: void cblas_ssyr2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  float alpha, float* A, int lda,
                  float* B, int ldb, float beta,
                  float* C, int ldc ) ;
FUNCTION: void cblas_strmm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 float alpha, float* A, int lda,
                 float* B, int ldb ) ;
FUNCTION: void cblas_strsm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 float alpha, float* A, int lda,
                 float* B, int ldb ) ;

FUNCTION: void cblas_dgemm ( CBLAS_ORDER Order, CBLAS_TRANSPOSE TransA,
                 CBLAS_TRANSPOSE TransB, int M, int N,
                 int K, double alpha, double* A,
                 int lda, double* B, int ldb,
                 double beta, double* C, int ldc ) ;
FUNCTION: void cblas_dsymm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 double alpha, double* A, int lda,
                 double* B, int ldb, double beta,
                 double* C, int ldc ) ;
FUNCTION: void cblas_dsyrk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 double alpha, double* A, int lda,
                 double beta, double* C, int ldc ) ;
FUNCTION: void cblas_dsyr2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  double alpha, double* A, int lda,
                  double* B, int ldb, double beta,
                  double* C, int ldc ) ;
FUNCTION: void cblas_dtrmm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 double alpha, double* A, int lda,
                 double* B, int ldb ) ;
FUNCTION: void cblas_dtrsm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 double alpha, double* A, int lda,
                 double* B, int ldb ) ;

FUNCTION: void cblas_cgemm ( CBLAS_ORDER Order, CBLAS_TRANSPOSE TransA,
                 CBLAS_TRANSPOSE TransB, int M, int N,
                 int K, void* alpha, void* A,
                 int lda, void* B, int ldb,
                 void* beta, void* C, int ldc ) ;
FUNCTION: void cblas_csymm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb, void* beta,
                 void* C, int ldc ) ;
FUNCTION: void cblas_csyrk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 void* alpha, void* A, int lda,
                 void* beta, void* C, int ldc ) ;
FUNCTION: void cblas_csyr2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  void* alpha, void* A, int lda,
                  void* B, int ldb, void* beta,
                  void* C, int ldc ) ;
FUNCTION: void cblas_ctrmm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb ) ;
FUNCTION: void cblas_ctrsm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb ) ;

FUNCTION: void cblas_zgemm ( CBLAS_ORDER Order, CBLAS_TRANSPOSE TransA,
                 CBLAS_TRANSPOSE TransB, int M, int N,
                 int K, void* alpha, void* A,
                 int lda, void* B, int ldb,
                 void* beta, void* C, int ldc ) ;
FUNCTION: void cblas_zsymm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb, void* beta,
                 void* C, int ldc ) ;
FUNCTION: void cblas_zsyrk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 void* alpha, void* A, int lda,
                 void* beta, void* C, int ldc ) ;
FUNCTION: void cblas_zsyr2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  void* alpha, void* A, int lda,
                  void* B, int ldb, void* beta,
                  void* C, int ldc ) ;
FUNCTION: void cblas_ztrmm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb ) ;
FUNCTION: void cblas_ztrsm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, CBLAS_TRANSPOSE TransA,
                 CBLAS_DIAG Diag, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb ) ;

FUNCTION: void cblas_chemm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb, void* beta,
                 void* C, int ldc ) ;
FUNCTION: void cblas_cherk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 float alpha, void* A, int lda,
                 float beta, void* C, int ldc ) ;
FUNCTION: void cblas_cher2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  void* alpha, void* A, int lda,
                  void* B, int ldb, float beta,
                  void* C, int ldc ) ;
FUNCTION: void cblas_zhemm ( CBLAS_ORDER Order, CBLAS_SIDE Side,
                 CBLAS_UPLO Uplo, int M, int N,
                 void* alpha, void* A, int lda,
                 void* B, int ldb, void* beta,
                 void* C, int ldc ) ;
FUNCTION: void cblas_zherk ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                 CBLAS_TRANSPOSE Trans, int N, int K,
                 double alpha, void* A, int lda,
                 double beta, void* C, int ldc ) ;
FUNCTION: void cblas_zher2k ( CBLAS_ORDER Order, CBLAS_UPLO Uplo,
                  CBLAS_TRANSPOSE Trans, int N, int K,
                  void* alpha, void* A, int lda,
                  void* B, int ldb, double beta,
                  void* C, int ldc ) ;

