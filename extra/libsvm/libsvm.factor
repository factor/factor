! Copyright (C) 2012 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data alien.libraries
alien.syntax arrays ascii assocs classes.struct combinators
destructors io.encodings.ascii io.files kernel libc math.parser
math.ranges sequences slots.syntax specialized-arrays
splitting system ;
IN: libsvm

<< "libsvm" {
    { [ os unix? ] [ "libsvm.so.2" ] }
} cond cdecl add-library >>

LIBRARY: libsvm

CONSTANT: LIBSVM_VERSION 312

! extern int libsvm_version;

STRUCT: svm_node
    { index int }
    { value double } ;

SPECIALIZED-ARRAY: svm_node

STRUCT: svm_problem
    { l int }
    { y double* }
    { x svm_node** } ;

ENUM: svm_type C_SVC NU_SVC ONE_CLASS EPSILON_SVR NU_SVR ; 
ENUM: kernel_type LINEAR POLY RBF SIGMOID PRECOMPUTED ;

STRUCT: svm_parameter
    { svm_type int }
    { kernel_type int }
    { degree int }
    { gamma double }
    { coef0 double }

    { cache_size double }
    { eps double }
    { C double }
    { nr_weight int }
    { weight_label int* }
    { weight double* }
    { nu double }
    { p double }
    { shrinking int }
    { probablility int } ;

STRUCT: svm_model
    { param svm_parameter }
    { nr_class int }
    { l int }
    { SV svm_node** }
    { sv_coef double** }
    { rho double* }
    { probA double* }
    { probB double* }
    { label int* }
    { nSV int* }
    { free_sv int } ;

FUNCTION: svm_model *svm_train ( svm_problem *prob, svm_parameter *param ) ;
FUNCTION: void svm_cross_validation ( svm_problem *prob, svm_parameter *param, int nr_fold, double *target ) ;

FUNCTION: int svm_save_model ( char *model_file_name, svm_model *model ) ;
FUNCTION: svm_model *svm_load_model ( char *model_file_name ) ;

FUNCTION: int svm_get_svm_type ( svm_model *model ) ;
FUNCTION: int svm_get_nr_class ( svm_model *model ) ;
FUNCTION: void svm_get_labels ( svm_model *model, int *label ) ;
FUNCTION: double svm_get_svr_probability ( svm_model *model ) ;

FUNCTION: double svm_predict_values ( svm_model *model, svm_node *x, double* dec_values ) ;
FUNCTION: double svm_predict ( svm_model *model, svm_node *x ) ;
FUNCTION: double svm_predict_probability ( svm_model *model, svm_node *x, double* prob_estimates ) ;

FUNCTION: void svm_free_model_content ( svm_model *model_ptr ) ;
FUNCTION: void svm_free_and_destroy_model ( svm_model **model_ptr_ptr ) ;
FUNCTION: void svm_destroy_param ( svm_parameter *param ) ;

FUNCTION: char *svm_check_parameter ( svm_problem *prob, svm_parameter *param ) ;
FUNCTION: int svm_check_probability_model ( svm_model *model ) ;

! FUNCTION: void svm_set_print_string_function ( void (*print_func)(const char *));
FUNCTION: void svm_set_print_string_function ( void *print_func ) ;


: load-svm-training-data ( path -- seq )
    ascii file-contents "\n" split harvest [
        " " split 1 cut-slice rest-slice
        [ first string>number ]
        [ [ ":" split [ string>number ] map ] map ] bi*
        2array
    ] map ;

: indexed-sequence>nodes ( seq -- svm_nodes )
    [ first2 svm_node <struct-boa> ] svm_node-array{ } map-as ;

: >indexed-sequence ( seq -- nodes )
    [ length [1,b] ] keep zip ;

: matrix>nodes ( seq -- nodes )
    [ >indexed-sequence indexed-sequence>nodes ] map concat
    \ svm_node malloc-like ;

: make-svm-problem ( X y -- svm-problem )
    [ svm_problem <struct> ] 2dip
        [ matrix>nodes >>x ]
        [ \ double malloc-like >>y ] bi* ;

M: svm_problem dispose
    [ slots{ x y } [ &free drop ] each ] with-destructors ;

! clear { { 100 200 300 400 500 } } { 1 1 1 0 0 } make-svm-problem
! svm_parameter <struct> svm_train
