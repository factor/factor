; ModuleID = 'vm/ffi_test_arm64_unions.c'
source_filename = "vm/ffi_test_arm64_unions.c"
target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "arm64-apple-macosx11.0.0"

%union.au_one = type { float }
%union.au_two = type { %struct.au_pair }
%struct.au_pair = type { float, float }
%union.au_four = type { %struct.au_quad }
%struct.au_quad = type { float, float, float, float }
%union.au_vector_two = type { %struct.au_fvec_pair }
%struct.au_fvec_pair = type { <4 x float>, <4 x float> }
%union.au_vector = type { <4 x float> }
%union.au_small = type { half }
%union.au_bsmall = type { bfloat }

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_one([1 x float] %0, double noundef %1) #0 {
  %3 = extractvalue [1 x float] %0, 0
  %4 = fpext float %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_two([2 x float] %0, double noundef %1) #0 {
  %3 = extractvalue [2 x float] %0, 0
  %4 = extractvalue [2 x float] %0, 1
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.000000e+00, float %3)
  %6 = fpext float %5 to double
  %7 = fadd double %1, %6
  ret double %7
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare float @llvm.fmuladd.f32(float, float, float) #1

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_four([4 x float] %0, double noundef %1) #0 {
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_nested([2 x float] %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [2 x float] %0, 0
  %4 = extractvalue [2 x float] %0, 1
  %5 = tail call float @llvm.fmuladd.f32(float %4, float 2.000000e+00, float %3)
  %6 = fpext float %5 to double
  %7 = fadd double %1, %6
  ret double %7
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_mixed(i64 %0, double noundef %1) local_unnamed_addr #0 {
  %3 = bitcast i64 %0 to double
  %4 = fadd double %1, %3
  ret double %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_padded([2 x i64] %0, double noundef %1) #0 {
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_padded_union([2 x i64] %0, double noundef %1) local_unnamed_addr #0 {
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_one @au_return_one(float noundef %0) local_unnamed_addr #0 {
  %2 = insertvalue %union.au_one poison, float %0, 0
  ret %union.au_one %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_two @au_return_two(float noundef %0, float noundef %1) local_unnamed_addr #0 {
  %3 = insertvalue %union.au_two poison, float %0, 0, 0
  %4 = insertvalue %union.au_two %3, float %1, 0, 1
  ret %union.au_two %4
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_four @au_return_four(float noundef %0, float noundef %1, float noundef %2, float noundef %3) local_unnamed_addr #0 {
  %5 = insertvalue %union.au_four poison, float %0, 0, 0
  %6 = insertvalue %union.au_four %5, float %1, 0, 1
  %7 = insertvalue %union.au_four %6, float %2, 0, 2
  %8 = insertvalue %union.au_four %7, float %3, 0, 3
  ret %union.au_four %8
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_one(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([1 x float] [float 1.250000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.start.p0(ptr captures(none)) #3

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite)
declare void @llvm.lifetime.end.p0(ptr captures(none)) #3

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_two(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_four(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn uwtable(sync)
define double @au_variadic(i32 noundef %0, ...) #4 {
  %2 = alloca ptr, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 8
  store ptr %4, ptr %2, align 8
  %5 = load float, ptr %3, align 8
  %6 = getelementptr inbounds nuw i8, ptr %3, i64 4
  %7 = load float, ptr %6, align 4, !tbaa !9
  %8 = va_arg ptr %2, double
  call void @llvm.va_end.p0(ptr nonnull %2)
  %9 = sitofp i32 %0 to float
  %10 = fadd float %5, %9
  %11 = call float @llvm.fmuladd.f32(float %7, float 2.000000e+00, float %10)
  %12 = fpext float %11 to double
  %13 = fadd double %8, %12
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %13
}

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_start.p0(ptr) #5

; Function Attrs: mustprogress nocallback nofree nosync nounwind willreturn
declare void @llvm.va_end.p0(ptr) #5

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_vector_two([2 x <4 x float>] %0, double noundef %1) local_unnamed_addr #0 {
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_vector_two @au_return_vector_two() local_unnamed_addr #0 {
  ret %union.au_vector_two { %struct.au_fvec_pair { <4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00> } }
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_vector_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x <4 x float>] [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00>], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_vector([1 x <4 x float>] %0, double noundef %1) #0 {
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_vector @au_return_vector(float noundef %0, float noundef %1, float noundef %2, float noundef %3) local_unnamed_addr #0 {
  %5 = insertelement <4 x float> poison, float %0, i64 0
  %6 = insertelement <4 x float> %5, float %1, i64 1
  %7 = insertelement <4 x float> %6, float %2, i64 2
  %8 = insertelement <4 x float> %7, float %3, i64 3
  %9 = insertvalue %union.au_vector poison, <4 x float> %8, 0
  ret %union.au_vector %9
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_vector(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([1 x <4 x float>] [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define [2 x i64] @au_return_padded(float noundef %0, float noundef %1) local_unnamed_addr #0 {
  %3 = bitcast float %0 to i32
  %4 = zext i32 %3 to i64
  %5 = insertvalue [2 x i64] poison, i64 %4, 0
  %6 = bitcast float %1 to i32
  %7 = zext i32 %6 to i64
  %8 = insertvalue [2 x i64] %5, i64 %7, 1
  ret [2 x i64] %8
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_padded(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x i64] [i64 1067450368, i64 1075838976], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_spill(double noundef %0, double noundef %1, double noundef %2, double noundef %3, double noundef %4, double noundef %5, [2 x float] %6, double noundef %7) #0 {
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

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_spill(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0(double noundef 1.000000e+00, double noundef 2.000000e+00, double noundef 3.000000e+00, double noundef 4.000000e+00, double noundef 5.000000e+00, double noundef 6.000000e+00, [2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define noundef i32 @au_vector_available() local_unnamed_addr #6 {
  ret i32 1
}

; Function Attrs: nounwind ssp uwtable(sync)
define range(i32 0, 2) i32 @au_c_controls() local_unnamed_addr #7 {
  %1 = tail call double @au_take_one([1 x float] [float 1.250000e+00], double noundef 1.000000e+01)
  %2 = fcmp une double %1, 1.125000e+01
  br i1 %2, label %84, label %3

3:                                                ; preds = %0
  %4 = tail call double @au_take_two([2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %5 = fcmp une double %4, 1.625000e+01
  br i1 %5, label %84, label %6

6:                                                ; preds = %3
  %7 = tail call double @au_take_four([4 x float] [float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00], double noundef 1.000000e+01)
  %8 = fcmp une double %7, 4.000000e+01
  br i1 %8, label %84, label %9

9:                                                ; preds = %6
  %10 = tail call double @au_take_nested([2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
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
  %39 = tail call double (i32, ...) @au_variadic(i32 noundef 7, [2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
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
  %60 = tail call double @au_take_spill(double noundef 1.000000e+00, double noundef 2.000000e+00, double noundef 3.000000e+00, double noundef 4.000000e+00, double noundef 5.000000e+00, double noundef 6.000000e+00, [2 x float] [float 1.250000e+00, float 2.500000e+00], double noundef 1.000000e+01)
  %61 = fcmp une double %60, 3.725000e+01
  br i1 %61, label %84, label %62

62:                                               ; preds = %59
  %63 = tail call double @au_call_spill(ptr noundef nonnull @au_take_spill)
  %64 = fcmp une double %63, 3.725000e+01
  br i1 %64, label %84, label %65

65:                                               ; preds = %62
  %66 = tail call double @au_take_vector_two([2 x <4 x float>] [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>, <4 x float> <float 5.000000e+00, float 6.000000e+00, float 7.000000e+00, float 8.000000e+00>], double noundef 1.000000e+01)
  %67 = fcmp une double %66, 4.600000e+01
  br i1 %67, label %84, label %68

68:                                               ; preds = %65
  %69 = tail call double @au_call_vector_variadic(ptr noundef nonnull @au_vector_variadic_control)
  %70 = fcmp une double %69, 5.300000e+01
  br i1 %70, label %84, label %71

71:                                               ; preds = %68
  %72 = tail call double @au_take_vector([1 x <4 x float>] [<4 x float> <float 1.000000e+00, float 2.000000e+00, float 3.000000e+00, float 4.000000e+00>], double noundef 1.000000e+01)
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

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn uwtable(sync)
define internal double @au_vector_variadic_control(i32 noundef %0, ...) #4 {
  %2 = alloca ptr, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 15
  %5 = call align 16 ptr @llvm.ptrmask.p0.i64(ptr nonnull %4, i64 -16)
  %6 = getelementptr inbounds nuw i8, ptr %5, i64 32
  store ptr %6, ptr %2, align 8
  %7 = load <4 x float>, ptr %5, align 16
  %8 = getelementptr inbounds nuw i8, ptr %5, i64 16
  %9 = load <4 x float>, ptr %8, align 16, !tbaa !9
  %10 = va_arg ptr %2, double
  call void @llvm.va_end.p0(ptr nonnull %2)
  %11 = sitofp i32 %0 to double
  %12 = insertvalue [2 x <4 x float>] poison, <4 x float> %7, 0
  %13 = insertvalue [2 x <4 x float>] %12, <4 x float> %9, 1
  %14 = call double @au_take_vector_two([2 x <4 x float>] %13, double noundef %10)
  %15 = fadd double %14, %11
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %15
}

; Function Attrs: nounwind ssp uwtable(sync)
define range(i32 0, 2) i32 @au_small_controls() local_unnamed_addr #7 {
  %1 = tail call %union.au_small @au_return_small(float noundef 1.250000e+00)
  %2 = extractvalue %union.au_small %1, 0
  %3 = tail call %union.au_bsmall @au_return_bsmall(float noundef 2.500000e+00)
  %4 = extractvalue %union.au_bsmall %3, 0
  %5 = fcmp une half %2, 1.250000e+00
  %6 = fcmp une bfloat %4, 2.500000e+00
  %7 = select i1 %5, i1 true, i1 %6
  br i1 %7, label %21, label %8

8:                                                ; preds = %0
  %9 = tail call double @au_take_small([1 x half] [half 1.250000e+00], double noundef 1.000000e+01)
  %10 = fcmp oeq double %9, 1.125000e+01
  br i1 %10, label %11, label %21

11:                                               ; preds = %8
  %12 = tail call double @au_take_bsmall([1 x bfloat] [bfloat 2.500000e+00], double noundef 1.000000e+01)
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

; Function Attrs: mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define noundef i32 @au_small_available() local_unnamed_addr #6 {
  ret i32 1
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_small([1 x half] %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [1 x half] %0, 0
  %4 = fpext half %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_bsmall([1 x bfloat] %0, double noundef %1) local_unnamed_addr #0 {
  %3 = extractvalue [1 x bfloat] %0, 0
  %4 = fpext bfloat %3 to double
  %5 = fadd double %1, %4
  ret double %5
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_small @au_return_small(float noundef %0) local_unnamed_addr #0 {
  %2 = fptrunc float %0 to half
  %3 = insertvalue %union.au_small poison, half %2, 0
  ret %union.au_small %3
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define %union.au_bsmall @au_return_bsmall(float noundef %0) local_unnamed_addr #0 {
  %2 = fptrunc float %0 to bfloat
  %3 = insertvalue %union.au_bsmall poison, bfloat %2, 0
  ret %union.au_bsmall %3
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync)
define double @au_take_small_pair([2 x half] %0, double noundef %1) #0 {
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

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_small_pair(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double %0([2 x half] [half 1.250000e+00, half 2.062500e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: noinline nounwind ssp uwtable(sync)
define double @au_call_small_variadic(ptr nofree noundef readonly captures(none) %0) local_unnamed_addr #2 {
  %2 = tail call double (i32, ...) %0(i32 noundef 7, [2 x half] [half 1.250000e+00, half 2.062500e+00], double noundef 1.000000e+01) #8
  ret double %2
}

; Function Attrs: mustprogress nofree noinline norecurse nosync nounwind ssp willreturn uwtable(sync)
define internal double @au_small_variadic_control(i32 noundef %0, ...) #4 {
  %2 = alloca ptr, align 8
  call void @llvm.lifetime.start.p0(ptr nonnull %2) #8
  call void @llvm.va_start.p0(ptr nonnull %2)
  %3 = load ptr, ptr %2, align 8
  %4 = getelementptr inbounds nuw i8, ptr %3, i64 8
  store ptr %4, ptr %2, align 8
  %5 = load half, ptr %3, align 8, !tbaa !9
  %6 = getelementptr inbounds nuw i8, ptr %3, i64 2
  %7 = load half, ptr %6, align 2, !tbaa !9
  %8 = va_arg ptr %2, double
  call void @llvm.va_end.p0(ptr nonnull %2)
  %9 = sitofp i32 %0 to double
  %10 = insertvalue [2 x half] poison, half %5, 0
  %11 = insertvalue [2 x half] %10, half %7, 1
  %12 = call double @au_take_small_pair([2 x half] %11, double noundef %8)
  %13 = fadd double %12, %9
  call void @llvm.lifetime.end.p0(ptr nonnull %2) #8
  ret double %13
}

; Function Attrs: mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare ptr @llvm.ptrmask.p0.i64(ptr, i64) #1

attributes #0 = { mustprogress nofree noinline norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #1 = { mustprogress nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { noinline nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #3 = { mustprogress nocallback nofree nosync nounwind willreturn memory(argmem: readwrite) }
attributes #4 = { mustprogress nofree noinline norecurse nosync nounwind ssp willreturn uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #5 = { mustprogress nocallback nofree nosync nounwind willreturn }
attributes #6 = { mustprogress nofree norecurse nosync nounwind ssp willreturn memory(none) uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #7 = { nounwind ssp uwtable(sync) "frame-pointer"="non-leaf-no-reserve" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" "tune-cpu"="apple-m5" }
attributes #8 = { nounwind }

!llvm.module.flags = !{!0, !1, !2}
!llvm.ident = !{!3}
!llvm.errno.tbaa = !{!4}

!0 = !{i32 8, !"PIC Level", i32 2}
!1 = !{i32 7, !"uwtable", i32 1}
!2 = !{i32 7, !"frame-pointer", i32 4}
!3 = !{!"Homebrew clang version 23.1.0"}
!4 = !{!5, !6, i64 0}
!5 = !{!"__libc_errno", !6, i64 0}
!6 = !{!"int", !7, i64 0}
!7 = !{!"omnipotent char", !8, i64 0}
!8 = !{!"Simple C/C++ TBAA"}
!9 = !{!7, !7, i64 0}
