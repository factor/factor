; ModuleID = 'reference/arm64-varargs-alignment-20260908/probe.c'
source_filename = "reference/arm64-varargs-alignment-20260908/probe.c"
target datalayout = "e-m:w-p270:32:32-p271:32:32-p272:64:64-p:64:64-i32:32-i64:64-i128:128-n32:64-S128-Fn32"
target triple = "aarch64-pc-windows-msvc19.33.0"

%struct.result = type { i64, <4 x float> }

; Function Attrs: nofree noinline nounwind memory(argmem: read) uwtable
define dso_local i64 @align_named(ptr noundef readonly captures(none) %0, ptr noundef %1, i32 noundef %2, ...) local_unnamed_addr #0 {
  %4 = ptrtoint ptr %1 to i64
  %5 = tail call i64 asm "", "=r,0"(i64 %4) #3, !srcloc !8
  %6 = and i64 %5, 15
  %7 = load i64, ptr %0, align 8
  %8 = sext i32 %2 to i64
  %9 = add nsw i64 %8, -2
  %10 = add i64 %9, %7
  %11 = add i64 %10, %6
  ret i64 %11
}

; Function Attrs: noinline nounwind memory(argmem: readwrite) uwtable
define dso_local void @align_return(ptr dead_on_unwind noalias writable writeonly sret(%struct.result) align 16 captures(none) initializes((0, 32)) %0, ptr noundef readonly captures(none) %1, i32 noundef %2, ...) local_unnamed_addr #1 {
  %4 = tail call i64 asm "", "={x8}"() #3, !srcloc !9
  tail call void @llvm.memset.p0.i64(ptr noundef nonnull align 16 dereferenceable(32) %0, i8 0, i64 16, i1 false)
  %5 = and i64 %4, 15
  %6 = load i64, ptr %1, align 8
  %7 = sext i32 %2 to i64
  %8 = add nsw i64 %7, -2
  %9 = add nsw i64 %8, %5
  %10 = add i64 %9, %6
  store i64 %10, ptr %0, align 16
  %11 = getelementptr inbounds nuw i8, ptr %0, i64 16
  store <4 x float> zeroinitializer, ptr %11, align 16
  ret void
}

; Function Attrs: mustprogress nocallback nofree nounwind willreturn memory(argmem: write)
declare void @llvm.memset.p0.i64(ptr writeonly captures(none), i8, i64, i1 immarg) #2

attributes #0 = { nofree noinline nounwind memory(argmem: read) uwtable "frame-pointer"="reserved" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #1 = { noinline nounwind memory(argmem: readwrite) uwtable "frame-pointer"="reserved" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="generic" "target-features"="+fp-armv8,+neon,+v8a,-fmv" }
attributes #2 = { mustprogress nocallback nofree nounwind willreturn memory(argmem: write) }
attributes #3 = { nounwind memory(none) }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2, !3, !4, !5, !6}
!llvm.ident = !{!7}

!0 = distinct !DICompileUnit(language: DW_LANG_C11, file: !1, producer: "Apple clang version 21.0.0 (clang-2100.1.1.101)", isOptimized: true, runtimeVersion: 0, emissionKind: NoDebug, splitDebugInlining: false, nameTableKind: None)
!1 = !DIFile(filename: "reference/arm64-varargs-alignment-20260908/probe.c", directory: "/Users/erg/factor.worktrees/arm64-varargs-outgoing")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = !{i32 1, !"wchar_size", i32 2}
!4 = !{i32 8, !"PIC Level", i32 2}
!5 = !{i32 7, !"uwtable", i32 2}
!6 = !{i32 7, !"frame-pointer", i32 3}
!7 = !{!"Apple clang version 21.0.0 (clang-2100.1.1.101)"}
!8 = !{i64 275}
!9 = !{i64 529}
