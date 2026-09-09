; ModuleID = 'vm/ffi_test_arm64_unions.c'
source_filename = "vm/ffi_test_arm64_unions.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-unknown-linux-gnu"

%union.au_one = type { float }
%union.au_two = type { %struct.au_pair }
%struct.au_pair = type { float, float }
%union.au_four = type { %struct.au_quad }
%struct.au_quad = type { float, float, float, float }
%struct.__va_list = type { ptr, ptr, ptr, i32, i32 }
%union.au_vector_two = type { %struct.au_fvec_pair }
%struct.au_fvec_pair = type { <4 x float>, <4 x float> }
%union.au_vector = type { <4 x float> }
%union.au_small = type { half }
%union.au_bsmall = type { bfloat }

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_one([1 x float] alignstack(8) %0, double noundef %1) #0 {
  %3 = extractvalue [1 x float] %0, 0
  %4 = fpext float %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_two([2 x float] alignstack(8) %0, double noundef %1) #0 {
  %3 = extractvalue [2 x float] %0, 0
  %4 = extractvalue [2 x float] %0, 1
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.000000e+00, float %3)
  %6 = fpext float %5 to double
  %7 = fadd double %1, %6
  ret double %7
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #1

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_four([4 x float] alignstack(8) %0, double noundef %1) #0 {
  %3 = extractvalue [4 x float] %0, 0
  %4 = extractvalue [4 x float] %0, 1
  %5 = extractvalue [4 x float] %0, 2
  %6 = extractvalue [4 x float] %0, 3
  %7 = tail call float @llvm.fmuladd.f32(float %4, float 2.000000e+00, float %3)
  %8 = tail call float @llvm.fmuladd.f32(float %5, float 3.000000e+00, float %7)
  %9 = tail call float @llvm.fmuladd.f32(float %6, float 4.000000e+00, float %8)
  %10 = fpext float %9 to double
  %11 = fadd double %1, %10
  ret double %11
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_nested([2 x float] alignstack(8) %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [2 x float] %0, 0
  %4 = extractvalue [2 x float] %0, 1
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.000000e+00, float %3)
  %6 = fpext float %5 to double
  %7 = fadd double %1, %6
  ret double %7
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_mixed(i64 %0, double noundef %1) local_unnamed_addr #0 {
  %3 = bitcast i64 %0 to double
  %4 = fadd double %1, %3
  ret double %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_padded([2 x i64] %0, double noundef %1) #0 {
  %3 = extractvalue [2 x i64] %0, 0
  %4 = trunc i64 %3 to i32
  %5 = bitcast i32 %4 to float
  %6 = extractvalue [2 x i64] %0, 1
  %7 = trunc i64 %6 to i32
  %8 = bitcast i32 %7 to float
  %9 = tail call float @llvm.fmuladd.f32(float %8, float 2.000000e+00, float %5)
  %10 = fpext float %9 to double
  %11 = fadd double %1, %10
  ret double %11
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_padded_union([2 x i64] %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [2 x i64] %0, 0
  %4 = trunc i64 %3 to i32
  %5 = bitcast i32 %4 to float
  %6 = extractvalue [2 x i64] %0, 1
  %7 = trunc i64 %6 to i32
  %8 = bitcast i32 %7 to float
  %9 = tail call float @llvm.fmuladd.f32(float %8, float 2.000000e+00, float %5)
  %10 = fpext float %9 to double
  %11 = fadd double %1, %10
  ret double %11
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_one @au_return_one(float noundef %0) local_unnamed_addr #0 {
  %2 = insertvalue %union.au_one poison, float %0, 0
  ret %union.au_one %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_two @au_return_two(float noundef %0, float noundef %1) local_unnamed_addr #0 {
  %3 = insertvalue %union.au_two poison, float %0, 0, 0
  %4 = insertvalue %union.au_two %3, float %1, 0, 1
  ret %union.au_two %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_four @au_return_four(float noundef %0, float noundef %1, float noundef %2, float noundef %3) local_unnamed_addr #0 {
  %5 = insertvalue %union.au_four poison, float %0, 0, 0
  %6 = insertvalue %union.au_four %5, float %1, 0, 1
  %7 = insertvalue %union.au_four %6, float %2, 0, 2
  %8 = insertvalue %union.au_four %7, float %3, 0, 3
  ret %union.au_four %8
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_one(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([1 x float] alignstack(8) [float 1.250000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #3

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_two(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_four(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([4 x float] alignstack(8) [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn uwtable
define dso_local double @au_variadic(i32 noundef %0, ...) #4 {
  %2 = alloca %struct.__va_list, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 28
  %4 = load i32, ptr %3, align 4
  %5 = icmp sgt i32 %4, -1
  br i1 %5, label %9, label %6

6:                                                ; preds = %1
  %7 = add nsw i32 %4, 32
  store i32 %7, ptr %3, align 4
  %8 = icmp samesign ult i32 %4, -31
  br i1 %8, label %15, label %9

9:                                                ; preds = %1, %6
  %10 = load ptr, ptr %2, align 8
  %11 = getelementptr inbounds nuw i8, ptr %10, i64 8
  store ptr %11, ptr %2, align 8
  %12 = getelementptr inbounds nuw i8, ptr %10, i64 4
  %13 = load float, ptr %10, align 4
  %14 = load float, ptr %12, align 4
  br label %32

15:                                               ; preds = %6
  %16 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %17 = load ptr, ptr %16, align 8
  %18 = sext i32 %4 to i64
  %19 = getelementptr inbounds i8, ptr %17, i64 %18
  %20 = getelementptr inbounds nuw i8, ptr %19, i64 16
  %21 = load float, ptr %19, align 4
  %22 = load float, ptr %20, align 4
  %23 = icmp sgt i32 %4, -33
  br i1 %23, label %32, label %24

24:                                               ; preds = %15
  %25 = add nsw i32 %4, 48
  store i32 %25, ptr %3, align 4
  %26 = icmp slt i32 %4, -47
  br i1 %26, label %27, label %32

27:                                               ; preds = %24
  %28 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %29 = load ptr, ptr %28, align 8
  %30 = sext i32 %7 to i64
  %31 = getelementptr inbounds i8, ptr %29, i64 %30
  br label %37

32:                                               ; preds = %9, %24, %15
  %33 = phi float [ %14, %9 ], [ %22, %24 ], [ %22, %15 ]
  %34 = phi float [ %13, %9 ], [ %21, %24 ], [ %21, %15 ]
  %35 = load ptr, ptr %2, align 8
  %36 = getelementptr inbounds nuw i8, ptr %35, i64 8
  store ptr %36, ptr %2, align 8
  br label %37

37:                                               ; preds = %32, %27
  %38 = phi float [ %22, %27 ], [ %33, %32 ]
  %39 = phi float [ %21, %27 ], [ %34, %32 ]
  %40 = phi ptr [ %31, %27 ], [ %35, %32 ]
  %41 = load double, ptr %40, align 8, !tbaa !16
  call void @llvm.va_end.p0(ptr nonnull %2)
  %42 = sitofp i32 %0 to float
  %43 = fadd float %39, %42
  %44 = call float @llvm.fmuladd.f32(float %38, float 2.000000e+00, float %43)
  %45 = fpext float %44 to double
  %46 = fadd double %41, %45
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %46
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_start.p0(ptr) #5

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_end.p0(ptr) #5

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_vector_two([2 x <4 x float>] alignstack(16) %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [2 x <4 x float>] %0, 0
  %4 = extractvalue [2 x <4 x float>] %0, 1
  %5 = shufflevector <4 x float> %3, <4 x float> poison, <4 x i32> <i32 1, i32 poison, i32 poison, i32 poison>
  %6 = fadd <4 x float> %3, %5
  %7 = shufflevector <4 x float> %3, <4 x float> poison, <4 x i32> <i32 2, i32 poison, i32 poison, i32 poison>
  %8 = fadd <4 x float> %7, %6
  %9 = shufflevector <4 x float> %3, <4 x float> poison, <4 x i32> <i32 3, i32 poison, i32 poison, i32 poison>
  %10 = fadd <4 x float> %9, %8
  %11 = fadd <4 x float> %4, %10
  %12 = shufflevector <4 x float> %4, <4 x float> poison, <4 x i32> <i32 1, i32 poison, i32 poison, i32 poison>
  %13 = fadd <4 x float> %12, %11
  %14 = shufflevector <4 x float> %4, <4 x float> poison, <4 x i32> <i32 2, i32 poison, i32 poison, i32 poison>
  %15 = fadd <4 x float> %14, %13
  %16 = shufflevector <4 x float> %4, <4 x float> poison, <4 x i32> <i32 3, i32 poison, i32 poison, i32 poison>
  %17 = fadd <4 x float> %16, %15
  %18 = extractelement <4 x float> %17, i64 0
  %19 = fpext float %18 to double
  %20 = fadd double %1, %19
  ret double %20
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_vector_two @au_return_vector_two() local_unnamed_addr #0 {
  ret %union.au_vector_two { %struct.au_fvec_pair { <4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00> } }
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_vector_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x <4 x float>] alignstack(16) [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00>], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_vector([1 x <4 x float>] alignstack(16) %0, double noundef %1) #0 {
  %3 = extractvalue [1 x <4 x float>] %0, 0
  %4 = extractelement <4 x float> %3, i64 0
  %5 = extractelement <4 x float> %3, i64 1
  %6 = tail call float @llvm.fmuladd.f32(float %5, float 2.000000e+00, float %4)
  %7 = extractelement <4 x float> %3, i64 2
  %8 = tail call float @llvm.fmuladd.f32(float %7, float 3.000000e+00, float %6)
  %9 = extractelement <4 x float> %3, i64 3
  %10 = tail call float @llvm.fmuladd.f32(float %9, float 4.000000e+00, float %8)
  %11 = fpext float %10 to double
  %12 = fadd double %1, %11
  ret double %12
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_vector @au_return_vector(float noundef %0, float noundef %1, float noundef %2, float noundef %3) local_unnamed_addr #0 {
  %5 = insertelement <4 x float> poison, float %0, i64 0
  %6 = insertelement <4 x float> %5, float %1, i64 1
  %7 = insertelement <4 x float> %6, float %2, i64 2
  %8 = insertelement <4 x float> %7, float %3, i64 3
  %9 = insertvalue %union.au_vector poison, <4 x float> %8, 0
  ret %union.au_vector %9
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_vector(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([1 x <4 x float>] alignstack(16) [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local [2 x i64] @au_return_padded(float noundef %0, float noundef %1) local_unnamed_addr #0 {
  %3 = bitcast float %0 to i32
  %4 = zext i32 %3 to i64
  %5 = insertvalue [2 x i64] poison, i64 %4, 0
  %6 = bitcast float %1 to i32
  %7 = zext i32 %6 to i64
  %8 = insertvalue [2 x i64] %5, i64 %7, 1
  ret [2 x i64] %8
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_padded(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x i64] [i64 1067450368, i64 1075838976], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_spill(double noundef %0, double noundef %1, double noundef %2, double noundef %3, double noundef %4, double noundef %5, [2 x float] alignstack(8) %6, double noundef %7) #0 {
  %9 = extractvalue [2 x float] %6, 0
  %10 = extractvalue [2 x float] %6, 1
  %11 = fadd double %0, %1
  %12 = fadd double %11, %2
  %13 = fadd double %12, %3
  %14 = fadd double %13, %4
  %15 = fadd double %14, %5
  %16 = fpext float %9 to double
  %17 = fadd double %15, %16
  %18 = fmul float %10, 2.000000e+00
  %19 = fpext float %18 to double
  %20 = fadd double %17, %19
  %21 = fadd double %7, %20
  ret double %21
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_spill(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0(double noundef 1.000000e+00, double noundef 2.000000e+00, double noundef 3.000000e+00, double noundef 4.000000e+00, double noundef 5.000000e+00, double noundef 6.000000e+00, [2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @au_vector_available() local_unnamed_addr #6 {
  ret i32 1
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 0, 2) i32 @au_c_controls() local_unnamed_addr #7 {
  %1 = tail call double @au_take_one([1 x float] alignstack(8) [float 1.250000e+00], double noundef 1.000000e+01)
  %2 = fcmp une double %1, 1.125000e+01
  br i1 %2, label %84, label %3

3:                                                ; preds = %0
  %4 = tail call double @au_take_two([2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %5 = fcmp une double %4, 1.625000e+01
  br i1 %5, label %84, label %6

6:                                                ; preds = %3
  %7 = tail call double @au_take_four([4 x float] alignstack(8) [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], double noundef 1.000000e+01)
  %8 = fcmp une double %7, 4.000000e+01
  br i1 %8, label %84, label %9

9:                                                ; preds = %6
  %10 = tail call double @au_take_nested([2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %11 = fcmp une double %10, 1.625000e+01
  br i1 %11, label %84, label %12

12:                                               ; preds = %9
  %13 = tail call double @au_take_mixed(i64 4615626668101337088, double noundef 1.000000e+01)
  %14 = fcmp une double %13, 1.375000e+01
  br i1 %14, label %84, label %15

15:                                               ; preds = %12
  %16 = tail call %union.au_one @au_return_one(float noundef 1.250000e+00)
  %17 = extractvalue %union.au_one %16, 0
  %18 = fcmp une float %17, 1.250000e+00
  br i1 %18, label %84, label %19

19:                                               ; preds = %15
  %20 = tail call %union.au_two @au_return_two(float noundef 1.250000e+00, float noundef 2.500000e+00)
  %21 = extractvalue %union.au_two %20, 0
  %22 = extractvalue %struct.au_pair %21, 1
  %23 = fcmp une float %22, 2.500000e+00
  br i1 %23, label %84, label %24

24:                                               ; preds = %19
  %25 = tail call %union.au_four @au_return_four(float noundef 1.000000e+00, float noundef 2.000000e+00, float noundef 3.000000e+00, float noundef 4.000000e+00)
  %26 = extractvalue %union.au_four %25, 0
  %27 = extractvalue %struct.au_quad %26, 3
  %28 = fcmp une float %27, 4.000000e+00
  br i1 %28, label %84, label %29

29:                                               ; preds = %24
  %30 = tail call double @au_call_one(ptr noundef nonnull @au_take_one)
  %31 = fcmp une double %30, 1.125000e+01
  br i1 %31, label %84, label %32

32:                                               ; preds = %29
  %33 = tail call double @au_call_two(ptr noundef nonnull @au_take_two)
  %34 = fcmp une double %33, 1.625000e+01
  br i1 %34, label %84, label %35

35:                                               ; preds = %32
  %36 = tail call double @au_call_four(ptr noundef nonnull @au_take_four)
  %37 = fcmp une double %36, 4.000000e+01
  br i1 %37, label %84, label %38

38:                                               ; preds = %35
  %39 = tail call double (i32, ...) @au_variadic(i32 noundef 7, [2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %40 = fcmp une double %39, 2.325000e+01
  br i1 %40, label %84, label %41

41:                                               ; preds = %38
  %42 = tail call double @au_call_variadic(ptr noundef nonnull @au_variadic)
  %43 = fcmp une double %42, 2.325000e+01
  br i1 %43, label %84, label %44

44:                                               ; preds = %41
  %45 = tail call double @au_take_padded([2 x i64] [i64 1067450368, i64 1075838976], double noundef 1.000000e+01)
  %46 = fcmp une double %45, 1.625000e+01
  br i1 %46, label %84, label %47

47:                                               ; preds = %44
  %48 = tail call double @au_take_padded_union([2 x i64] [i64 1067450368, i64 1075838976], double noundef 1.000000e+01)
  %49 = fcmp une double %48, 1.625000e+01
  br i1 %49, label %84, label %50

50:                                               ; preds = %47
  %51 = tail call [2 x i64] @au_return_padded(float noundef 1.250000e+00, float noundef 2.500000e+00)
  %52 = extractvalue [2 x i64] %51, 1
  %53 = trunc i64 %52 to i32
  %54 = bitcast i32 %53 to float
  %55 = fcmp une float %54, 2.500000e+00
  br i1 %55, label %84, label %56

56:                                               ; preds = %50
  %57 = tail call double @au_call_padded(ptr noundef nonnull @au_take_padded)
  %58 = fcmp une double %57, 1.625000e+01
  br i1 %58, label %84, label %59

59:                                               ; preds = %56
  %60 = tail call double @au_take_spill(double noundef 1.000000e+00, double noundef 2.000000e+00, double noundef 3.000000e+00, double noundef 4.000000e+00, double noundef 5.000000e+00, double noundef 6.000000e+00, [2 x float] alignstack(8) [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %61 = fcmp une double %60, 3.725000e+01
  br i1 %61, label %84, label %62

62:                                               ; preds = %59
  %63 = tail call double @au_call_spill(ptr noundef nonnull @au_take_spill)
  %64 = fcmp une double %63, 3.725000e+01
  br i1 %64, label %84, label %65

65:                                               ; preds = %62
  %66 = tail call double @au_take_vector_two([2 x <4 x float>] alignstack(16) [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00>], double noundef 1.000000e+01)
  %67 = fcmp une double %66, 4.600000e+01
  br i1 %67, label %84, label %68

68:                                               ; preds = %65
  %69 = tail call double @au_call_vector_variadic(ptr noundef nonnull @au_vector_variadic_control)
  %70 = fcmp une double %69, 5.300000e+01
  br i1 %70, label %84, label %71

71:                                               ; preds = %68
  %72 = tail call double @au_take_vector([1 x <4 x float>] alignstack(16) [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>], double noundef 1.000000e+01)
  %73 = fcmp une double %72, 4.000000e+01
  br i1 %73, label %84, label %74

74:                                               ; preds = %71
  %75 = tail call %union.au_vector @au_return_vector(float noundef 1.000000e+00, float noundef 2.000000e+00, float noundef 3.000000e+00, float noundef 4.000000e+00)
  %76 = extractvalue %union.au_vector %75, 0
  %77 = extractelement <4 x float> %76, i64 3
  %78 = fcmp une float %77, 4.000000e+00
  br i1 %78, label %84, label %79

79:                                               ; preds = %74
  %80 = tail call double @au_call_vector(ptr noundef nonnull @au_take_vector)
  %81 = fcmp une double %80, 4.000000e+01
  br i1 %81, label %84, label %82

82:                                               ; preds = %79
  %83 = tail call i32 @au_small_controls()
  br label %84

84:                                               ; preds = %68, %65, %74, %71, %79, %82, %59, %62, %56, %44, %47, %50, %38, %41, %29, %32, %35, %24, %15, %19, %0, %3, %6, %9, %12
  %85 = phi i32 [ 0, %59 ], [ 0, %0 ], [ 0, %24 ], [ 0, %29 ], [ 0, %38 ], [ 0, %56 ], [ 0, %12 ], [ 0, %9 ], [ 0, %6 ], [ 0, %3 ], [ 0, %19 ], [ 0, %15 ], [ 0, %35 ], [ 0, %32 ], [ 0, %41 ], [ 0, %50 ], [ 0, %47 ], [ 0, %44 ], [ 0, %62 ], [ %83, %82 ], [ 0, %65 ], [ 0, %79 ], [ 0, %68 ], [ 0, %74 ], [ 0, %71 ]
  ret i32 %85
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn uwtable
define internal double @au_vector_variadic_control(i32 noundef %0, ...) #4 {
  %2 = alloca %struct.__va_list, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 28
  %4 = load i32, ptr %3, align 4
  %5 = icmp sgt i32 %4, -1
  br i1 %5, label %9, label %6

6:                                                ; preds = %1
  %7 = add nsw i32 %4, 32
  store i32 %7, ptr %3, align 4
  %8 = icmp samesign ult i32 %4, -31
  br i1 %8, label %17, label %9

9:                                                ; preds = %1, %6
  %10 = load ptr, ptr %2, align 8
  %11 = getelementptr inbounds nuw i8, ptr %10, i64 15
  %12 = call align 16 ptr @llvm.ptrmask.p0.i64(ptr nonnull %11, i64 -16)
  %13 = getelementptr inbounds nuw i8, ptr %12, i64 32
  store ptr %13, ptr %2, align 8
  %14 = load <4 x float>, ptr %12, align 16
  %15 = getelementptr inbounds nuw i8, ptr %12, i64 16
  %16 = load <4 x float>, ptr %15, align 16
  br label %34

17:                                               ; preds = %6
  %18 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %19 = load ptr, ptr %18, align 8
  %20 = sext i32 %4 to i64
  %21 = getelementptr inbounds i8, ptr %19, i64 %20
  %22 = load <4 x float>, ptr %21, align 16
  %23 = getelementptr inbounds nuw i8, ptr %21, i64 16
  %24 = load <4 x float>, ptr %23, align 16
  %25 = icmp sgt i32 %4, -33
  br i1 %25, label %34, label %26

26:                                               ; preds = %17
  %27 = add nsw i32 %4, 48
  store i32 %27, ptr %3, align 4
  %28 = icmp slt i32 %4, -47
  br i1 %28, label %29, label %34

29:                                               ; preds = %26
  %30 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %31 = load ptr, ptr %30, align 8
  %32 = sext i32 %7 to i64
  %33 = getelementptr inbounds i8, ptr %31, i64 %32
  br label %39

34:                                               ; preds = %9, %26, %17
  %35 = phi <4 x float> [ %16, %9 ], [ %24, %26 ], [ %24, %17 ]
  %36 = phi <4 x float> [ %14, %9 ], [ %22, %26 ], [ %22, %17 ]
  %37 = load ptr, ptr %2, align 8
  %38 = getelementptr inbounds nuw i8, ptr %37, i64 8
  store ptr %38, ptr %2, align 8
  br label %39

39:                                               ; preds = %34, %29
  %40 = phi <4 x float> [ %24, %29 ], [ %35, %34 ]
  %41 = phi <4 x float> [ %22, %29 ], [ %36, %34 ]
  %42 = phi ptr [ %33, %29 ], [ %37, %34 ]
  %43 = load double, ptr %42, align 8, !tbaa !16
  call void @llvm.va_end.p0(ptr nonnull %2)
  %44 = sitofp i32 %0 to double
  %45 = insertvalue [2 x <4 x float>] poison, <4 x float> %41, 0
  %46 = insertvalue [2 x <4 x float>] %45, <4 x float> %40, 1
  %47 = call double @au_take_vector_two([2 x <4 x float>] alignstack(16) %46, double noundef %43)
  %48 = fadd double %47, %44
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %48
}

; Function Attrs: nounwind uwtable
define dso_local range(i32 0, 2) i32 @au_small_controls() local_unnamed_addr #7 {
  %1 = tail call %union.au_small @au_return_small(float noundef 1.250000e+00)
  %2 = extractvalue %union.au_small %1, 0
  %3 = tail call %union.au_bsmall @au_return_bsmall(float noundef 2.500000e+00)
  %4 = extractvalue %union.au_bsmall %3, 0
  %5 = fcmp une half %2, 1.250000e+00
  %6 = fcmp une bfloat %4, 2.500000e+00
  %7 = select i1 %5, i1 true, i1 %6
  br i1 %7, label %21, label %8

8:                                                ; preds = %0
  %9 = tail call double @au_take_small([1 x half] alignstack(8) [half 1.250000e+00], double noundef 1.000000e+01)
  %10 = fcmp oeq double %9, 1.125000e+01
  br i1 %10, label %11, label %21

11:                                               ; preds = %8
  %12 = tail call double @au_take_bsmall([1 x bfloat] alignstack(8) [bfloat 2.500000e+00], double noundef 1.000000e+01)
  %13 = fcmp oeq double %12, 1.250000e+01
  br i1 %13, label %14, label %21

14:                                               ; preds = %11
  %15 = tail call double @au_call_small_pair(ptr noundef nonnull @au_take_small_pair)
  %16 = fcmp oeq double %15, 1.625000e+01
  br i1 %16, label %17, label %21

17:                                               ; preds = %14
  %18 = tail call double @au_call_small_variadic(ptr noundef nonnull @au_small_variadic_control)
  %19 = fcmp oeq double %18, 2.325000e+01
  %20 = zext i1 %19 to i32
  br label %21

21:                                               ; preds = %8, %11, %14, %17, %0
  %22 = phi i32 [ 0, %0 ], [ 0, %14 ], [ 0, %11 ], [ 0, %8 ], [ %20, %17 ]
  ret i32 %22
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local noundef i32 @au_small_available() local_unnamed_addr #6 {
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_small([1 x half] alignstack(8) %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [1 x half] %0, 0
  %4 = fpext half %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_bsmall([1 x bfloat] alignstack(8) %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [1 x bfloat] %0, 0
  %4 = fpext bfloat %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_small @au_return_small(float noundef %0) local_unnamed_addr #0 {
  %2 = fptrunc float %0 to half
  %3 = insertvalue %union.au_small poison, half %2, 0
  ret %union.au_small %3
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local %union.au_bsmall @au_return_bsmall(float noundef %0) local_unnamed_addr #0 {
  %2 = fptrunc float %0 to bfloat
  %3 = insertvalue %union.au_bsmall poison, bfloat %2, 0
  ret %union.au_bsmall %3
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable
define dso_local double @au_take_small_pair([2 x half] alignstack(8) %0, double noundef %1) #0 {
  %3 = extractvalue [2 x half] %0, 0
  %4 = extractvalue [2 x half] %0, 1
  %5 = bitcast half %4 to bfloat
  %6 = fpext half %3 to double
  %7 = fpext bfloat %5 to double
  %8 = tail call double @llvm.fmuladd.f64(double %7, double 2.000000e+00, double %6)
  %9 = fadd double %1, %8
  ret double %9
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare double @llvm.fmuladd.f64(double, double, double) #1

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_small_pair(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x half] alignstack(8) [half 1.250000e+00, half 2.062500e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @au_call_small_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x half] alignstack(8) [half 1.250000e+00, half 2.062500e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind willreturn uwtable
define internal double @au_small_variadic_control(i32 noundef %0, ...) #4 {
  %2 = alloca %struct.__va_list, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = getelementptr inbounds nuw i8, ptr %2, i64 28
  %4 = load i32, ptr %3, align 4
  %5 = icmp sgt i32 %4, -1
  br i1 %5, label %9, label %6

6:                                                ; preds = %1
  %7 = add nsw i32 %4, 32
  store i32 %7, ptr %3, align 4
  %8 = icmp samesign ult i32 %4, -31
  br i1 %8, label %15, label %9

9:                                                ; preds = %1, %6
  %10 = load ptr, ptr %2, align 8
  %11 = getelementptr inbounds nuw i8, ptr %10, i64 8
  store ptr %11, ptr %2, align 8
  %12 = getelementptr inbounds nuw i8, ptr %10, i64 2
  %13 = load half, ptr %10, align 2
  %14 = load half, ptr %12, align 2
  br label %32

15:                                               ; preds = %6
  %16 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %17 = load ptr, ptr %16, align 8
  %18 = sext i32 %4 to i64
  %19 = getelementptr inbounds i8, ptr %17, i64 %18
  %20 = getelementptr inbounds nuw i8, ptr %19, i64 16
  %21 = load half, ptr %19, align 2
  %22 = load half, ptr %20, align 2
  %23 = icmp sgt i32 %4, -33
  br i1 %23, label %32, label %24

24:                                               ; preds = %15
  %25 = add nsw i32 %4, 48
  store i32 %25, ptr %3, align 4
  %26 = icmp slt i32 %4, -47
  br i1 %26, label %27, label %32

27:                                               ; preds = %24
  %28 = getelementptr inbounds nuw i8, ptr %2, i64 16
  %29 = load ptr, ptr %28, align 8
  %30 = sext i32 %7 to i64
  %31 = getelementptr inbounds i8, ptr %29, i64 %30
  br label %37

32:                                               ; preds = %9, %24, %15
  %33 = phi half [ %14, %9 ], [ %22, %24 ], [ %22, %15 ]
  %34 = phi half [ %13, %9 ], [ %21, %24 ], [ %21, %15 ]
  %35 = load ptr, ptr %2, align 8
  %36 = getelementptr inbounds nuw i8, ptr %35, i64 8
  store ptr %36, ptr %2, align 8
  br label %37

37:                                               ; preds = %32, %27
  %38 = phi half [ %22, %27 ], [ %33, %32 ]
  %39 = phi half [ %21, %27 ], [ %34, %32 ]
  %40 = phi ptr [ %31, %27 ], [ %35, %32 ]
  %41 = load double, ptr %40, align 8, !tbaa !16
  call void @llvm.va_end.p0(ptr nonnull %2)
  %42 = sitofp i32 %0 to double
  %43 = insertvalue [2 x half] poison, half %39, 0
  %44 = insertvalue [2 x half] %43, half %38, 1
  %45 = call double @au_take_small_pair([2 x half] alignstack(8) %44, double noundef %41)
  %46 = fadd double %45, %42
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %46
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare ptr @llvm.ptrmask.p0.i64(ptr, i64) #1

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind willreturn memory(none) uwtable "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #1 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { noinline nounwind uwtable "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress nofree noinline norecurse nosync nounwind willreturn uwtable "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #5 = { mustprogress nocallback nofree nosync nounwind willreturn }
attributes #6 = { mustprogress nofree norecurse nosync nounwind willreturn memory(none) uwtable "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #7 = { nounwind uwtable "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1, !2, !3, !4, !5, !6, !7, !8, !9}
!llvm.ident = !{!10}
!llvm.errno.tbaa = !{!11}

!0 = !{i32 1, !"ptrauth-elf-got", i32 0}
!1 = !{i32 1, !"ptrauth-init-fini", i32 0}
!2 = !{i32 1, !"ptrauth-init-fini-address-discrimination", i32 0}
!3 = !{i32 1, !"ptrauth-sign-personality", i32 0}
!4 = !{i32 1, !"aarch64-elf-pauthabi-platform", i32 268435458}
!5 = !{i32 1, !"aarch64-elf-pauthabi-version", i32 0}
!6 = !{i32 8, !"PIC Level", i32 2}
!7 = !{i32 7, !"PIE Level", i32 2}
!8 = !{i32 7, !"uwtable", i32 2}
!9 = !{i32 7, !"frame-pointer", i32 4}
!10 = !{!"Homebrew clang version 23.1.0"}
!11 = !{!12, !13, i64 0}
!12 = !{!"__libc_errno", !13, i64 0}
!13 = !{!"int", !14, i64 0}
!14 = !{!"omnipotent char", !15, i64 0}
!15 = !{!"Simple C/C++ TBAA"}
!16 = !{!17, !17, i64 0}
!17 = !{!"double", !14, i64 0}
