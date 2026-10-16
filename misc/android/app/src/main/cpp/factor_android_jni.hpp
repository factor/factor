#pragma once

#include <jni.h>
#include <functional>

// Factor's managed stack is deliberately small. Dispatch Java work to one
// attached native thread with a normal OS stack and wait for its result.
// Calls are serialized and temporary local references are released per call.
// Work must not dispatch further work; retain escaping objects as global refs.
// Returns false for empty work, failed attachment or frame allocation, or
// a Java exception left pending by work.
bool factor_android_dispatch_java(std::function<void(JNIEnv*)> work);
