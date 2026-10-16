#include "factor_android.h"
#include "factor_android_jni.hpp"

#include <array>
#include <atomic>
#include <cassert>
#include <iostream>
#include <string>
#include <thread>
#include <vector>

namespace {
JNINativeInterface native_api{};
JNIInvokeInterface invoke_api{};
JNIEnv environment{&native_api};
JavaVM vm{&invoke_api};
std::thread::id worker_id;
std::atomic<int> attachments{0};
std::atomic<int> frames{0};
std::atomic<int> pushes{0};
std::atomic<int> pops{0};
std::atomic<int> reports{0};
std::atomic<bool> exception_pending{false};
std::atomic<bool> fail_frame{false};
bool fail_attachment = false;
bool missing_vm = false;

jint attach(JavaVM*, JNIEnv** env, void*) {
  ++attachments;
  worker_id = std::this_thread::get_id();
  if (fail_attachment) return JNI_ERR;
  *env = &environment;
  return JNI_OK;
}

jint push_frame(JNIEnv*, jint capacity) {
  assert(std::this_thread::get_id() == worker_id && capacity > 0);
  if (fail_frame.exchange(false)) {
    exception_pending = true;
    return JNI_ERR;
  }
  assert(frames.fetch_add(1) == 0);
  ++pushes;
  return JNI_OK;
}

jobject pop_frame(JNIEnv*, jobject result) {
  assert(std::this_thread::get_id() == worker_id && !result);
  assert(frames.fetch_sub(1) == 1);
  ++pops;
  return nullptr;
}
}  // namespace

extern "C" JavaVM* factor_android_java_vm() { return missing_vm ? nullptr : &vm; }

int main(int argc, char** argv) {
  fail_attachment = argc == 2 && std::string(argv[1]) == "attach-failure";
  missing_vm = argc == 2 && std::string(argv[1]) == "missing-vm";
  invoke_api.AttachCurrentThread = attach;
  native_api.PushLocalFrame = push_frame;
  native_api.PopLocalFrame = pop_frame;
  native_api.ExceptionCheck = [](JNIEnv*) -> jboolean { return exception_pending; };
  native_api.ExceptionDescribe = [](JNIEnv*) { ++reports; };
  native_api.ExceptionClear = [](JNIEnv*) { exception_pending = false; };
  assert(!factor_android_dispatch_java({}));
  assert(attachments == 0);

  // Race the first dispatch and repeated requests from distinct native callers.
  // Each caller must wait for its own callback, on the one attached worker.
  constexpr int caller_count = 24;
  constexpr int iterations = 100;
  std::array<int, caller_count> completed{};
  std::atomic<bool> start{false};
  std::vector<std::thread> callers;
  for (int i = 0; i < caller_count; ++i) {
    callers.emplace_back([&, i] {
      while (!start) std::this_thread::yield();
      for (int call = 0; call < iterations; ++call) {
        bool ran = false;
        const bool dispatched = factor_android_dispatch_java([&](JNIEnv* env) {
          assert(env == &environment);
          assert(std::this_thread::get_id() == worker_id);
          assert(frames == 1);
          std::this_thread::yield();
          ++completed[i];
          ran = true;
        });
        assert(dispatched == !(fail_attachment || missing_vm));
        assert(ran == dispatched);
        assert(completed[i] == (dispatched ? call + 1 : 0));
      }
    });
  }
  start = true;
  for (auto& caller : callers) caller.join();
  assert(attachments == (missing_vm ? 0 : 1));
  assert(frames == 0);
  if (fail_attachment || missing_vm) {
    assert(pushes == 0 && pops == 0);
    std::cout << "Java attachment failure checks passed\n";
    return 0;
  }
  assert(pushes == caller_count * iterations && pops == pushes);

  // Failed frame allocation skips the callback and clears its Java exception.
  bool ran = false;
  fail_frame = true;
  assert(!factor_android_dispatch_java([&](JNIEnv*) { ran = true; }));
  assert(!ran && !exception_pending && frames == 0);

  // An exception in one request cannot poison the next request's environment.
  assert(!factor_android_dispatch_java([](JNIEnv*) { exception_pending = true; }));
  assert(!exception_pending && frames == 0);
  assert(factor_android_dispatch_java([&](JNIEnv*) { ran = true; }));
  assert(ran && frames == 0 && pushes == pops && reports == 2);
  std::cout << "Java dispatch checks passed: 2400 concurrent requests, one worker\n";
}
