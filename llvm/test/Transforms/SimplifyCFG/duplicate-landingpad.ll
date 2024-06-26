; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -passes=simplifycfg -simplifycfg-require-and-preserve-domtree=1 -S | FileCheck %s
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"

declare i32 @__gxx_personality_v0(...)
declare void @fn()


define void @test1() personality ptr @__gxx_personality_v0 {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[INVOKE2:%.*]] unwind label [[LPAD2:%.*]]
; CHECK:       invoke2:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[COMMON_RET:%.*]] unwind label [[LPAD2]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       lpad2:
; CHECK-NEXT:    [[EXN2:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            cleanup
; CHECK-NEXT:    call void @fn()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  invoke void @fn()
  to label %invoke2 unwind label %lpad1

invoke2:
  invoke void @fn()
  to label %invoke.cont unwind label %lpad2

invoke.cont:
  ret void

lpad1:
  %exn = landingpad {ptr, i32}
  cleanup
  br label %shared_resume

lpad2:
  %exn2 = landingpad {ptr, i32}
  cleanup
  br label %shared_resume

shared_resume:
  call void @fn()
  ret void
}

; Don't trigger if blocks aren't the same/empty
define void @neg1() personality ptr @__gxx_personality_v0 {
; CHECK-LABEL: @neg1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[INVOKE2:%.*]] unwind label [[LPAD1:%.*]]
; CHECK:       invoke2:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[COMMON_RET:%.*]] unwind label [[LPAD2:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       lpad1:
; CHECK-NEXT:    [[EXN:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            filter [0 x ptr] zeroinitializer
; CHECK-NEXT:    call void @fn()
; CHECK-NEXT:    br label [[SHARED_RESUME:%.*]]
; CHECK:       lpad2:
; CHECK-NEXT:    [[EXN2:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            cleanup
; CHECK-NEXT:    br label [[SHARED_RESUME]]
; CHECK:       shared_resume:
; CHECK-NEXT:    call void @fn()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  invoke void @fn()
  to label %invoke2 unwind label %lpad1

invoke2:
  invoke void @fn()
  to label %invoke.cont unwind label %lpad2

invoke.cont:
  ret void

lpad1:
  %exn = landingpad {ptr, i32}
  filter [0 x ptr] zeroinitializer
  call void @fn()
  br label %shared_resume

lpad2:
  %exn2 = landingpad {ptr, i32}
  cleanup
  br label %shared_resume

shared_resume:
  call void @fn()
  ret void
}

; Should not trigger when the landing pads are not the exact same
define void @neg2() personality ptr @__gxx_personality_v0 {
; CHECK-LABEL: @neg2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[INVOKE2:%.*]] unwind label [[LPAD1:%.*]]
; CHECK:       invoke2:
; CHECK-NEXT:    invoke void @fn()
; CHECK-NEXT:            to label [[COMMON_RET:%.*]] unwind label [[LPAD2:%.*]]
; CHECK:       common.ret:
; CHECK-NEXT:    ret void
; CHECK:       lpad1:
; CHECK-NEXT:    [[EXN:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            filter [0 x ptr] zeroinitializer
; CHECK-NEXT:    br label [[SHARED_RESUME:%.*]]
; CHECK:       lpad2:
; CHECK-NEXT:    [[EXN2:%.*]] = landingpad { ptr, i32 }
; CHECK-NEXT:            cleanup
; CHECK-NEXT:    br label [[SHARED_RESUME]]
; CHECK:       shared_resume:
; CHECK-NEXT:    call void @fn()
; CHECK-NEXT:    br label [[COMMON_RET]]
;
entry:
  invoke void @fn()
  to label %invoke2 unwind label %lpad1

invoke2:
  invoke void @fn()
  to label %invoke.cont unwind label %lpad2

invoke.cont:
  ret void

lpad1:
  %exn = landingpad {ptr, i32}
  filter [0 x ptr] zeroinitializer
  br label %shared_resume

lpad2:
  %exn2 = landingpad {ptr, i32}
  cleanup
  br label %shared_resume

shared_resume:
  call void @fn()
  ret void
}
