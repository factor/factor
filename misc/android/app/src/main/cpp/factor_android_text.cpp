#include "factor_android_text.h"
#include "factor_android.h"
#include "factor_android_jni.hpp"
#include "factor_android_utf.h"

#include <android/bitmap.h>
#include <jni.h>
#include <algorithm>
#include <array>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

namespace {
struct methods {
  jclass type = nullptr;
  jmethodID constructor = nullptr, metrics = nullptr;
  jmethodID offset_x = nullptr, x_offset = nullptr;
  jmethodID spans = nullptr, render = nullptr;
};
methods api;
bool clear_exception(JNIEnv* env) {
  if (!env->ExceptionCheck()) return false;
  env->ExceptionDescribe();
  env->ExceptionClear();
  return true;
}

void load_api(JNIEnv* env, jclass local) {
  methods found;
  found.type = static_cast<jclass>(env->NewGlobalRef(local));
  if (clear_exception(env) || !found.type) return;
  found.constructor = env->GetMethodID(found.type, "<init>",
                                       "(Ljava/lang/String;Ljava/lang/String;FZZ)V");
  auto get_method = [&](const char* method, const char* signature) {
    return env->ExceptionCheck() ? static_cast<jmethodID>(nullptr)
                                 : env->GetMethodID(found.type, method, signature);
  };
  found.metrics = get_method("metrics", "()[F");
  found.offset_x = get_method("offsetX", "(I)F");
  found.x_offset = get_method("xOffset", "(F)I");
  found.spans = get_method("selectionSpans", "(II)[F");
  found.render = get_method("render", "(IIIII)Landroid/graphics/Bitmap;");
  if (clear_exception(env) || !found.constructor || !found.metrics ||
      !found.offset_x || !found.x_offset || !found.spans || !found.render) {
    env->DeleteGlobalRef(found.type);
    return;
  }
  api = found;
}

struct text { jobject object; };
}

extern "C" JNIEXPORT void JNICALL
Java_org_factorcode_factor_FactorActivity_nativeInitializeText(
    JNIEnv* env, jclass, jclass type) {
  if (!api.type) load_api(env, type);
}

extern "C" void* factor_android_text_create(const uint8_t* value, size_t length,
                                               const char* family,
                                               float size, int bold, int italic) {
  text* result = nullptr;
  std::u16string contents = factor_utf8_to_utf16(value, length);
  std::string font(family);
  factor_android_dispatch_java([&](JNIEnv* env) {
    jstring string = env->NewString(reinterpret_cast<const jchar*>(contents.data()),
                                    contents.size());
    jstring name = env->NewStringUTF(font.c_str());
    jvalue arguments[5]{};
    arguments[0].l = string;
    arguments[1].l = name;
    arguments[2].f = size;
    arguments[3].z = static_cast<jboolean>(bold);
    arguments[4].z = static_cast<jboolean>(italic);
    jobject local = env->NewObjectA(api.type, api.constructor, arguments);
    if (!clear_exception(env) && local) {
      result = new text{env->NewGlobalRef(local)};
    }
    if (local) env->DeleteLocalRef(local);
    env->DeleteLocalRef(name);
    env->DeleteLocalRef(string);
  });
  return result;
}

extern "C" void factor_android_text_destroy(void* pointer) {
  if (!pointer) return;
  text* value = static_cast<text*>(pointer);
  factor_android_dispatch_java([&](JNIEnv* env) { env->DeleteGlobalRef(value->object); });
  delete value;
}

extern "C" int factor_android_text_metrics(
    void* pointer, struct factor_android_text_metrics* out) {
  if (!pointer || !out) return 0;
  int success = 0;
  std::array<float, 7> values{};
  factor_android_dispatch_java([&](JNIEnv* env) {
    jfloatArray array = static_cast<jfloatArray>(env->CallObjectMethod(static_cast<text*>(pointer)->object, api.metrics));
    if (!clear_exception(env) && array && env->GetArrayLength(array) == 7) {
      env->GetFloatArrayRegion(array, 0, 7, values.data());
      success = 1;
    }
    if (array) env->DeleteLocalRef(array);
  });
  if (success) memcpy(&out->width, values.data(), sizeof(values));
  return success;
}

extern "C" float factor_android_text_offset_x(void* pointer, int offset) {
  if (!pointer) return 0;
  float value = 0;
  factor_android_dispatch_java([&](JNIEnv* env) { value = env->CallFloatMethod(static_cast<text*>(pointer)->object, api.offset_x, offset); clear_exception(env); });
  return value;
}
extern "C" int factor_android_text_x_offset(void* pointer, float x) {
  if (!pointer) return 0;
  int value = 0;
  factor_android_dispatch_java([&](JNIEnv* env) { value = env->CallIntMethod(static_cast<text*>(pointer)->object, api.x_offset, x); clear_exception(env); });
  return value;
}
extern "C" int factor_android_text_selection_spans(void* pointer, int start, int end,
                                                     float* output, int capacity) {
  if (!pointer) return 0;
  int count = 0;
  std::vector<float> values;
  factor_android_dispatch_java([&](JNIEnv* env) {
    jfloatArray array = static_cast<jfloatArray>(env->CallObjectMethod(static_cast<text*>(pointer)->object, api.spans, start, end));
    if (!clear_exception(env) && array) {
      count = env->GetArrayLength(array);
      if (output && capacity > 0) {
        values.resize(static_cast<size_t>(std::min(count, capacity)));
        env->GetFloatArrayRegion(array, 0, values.size(), values.data());
      }
    }
    if (array) env->DeleteLocalRef(array);
  });
  if (!values.empty()) memcpy(output, values.data(), values.size() * sizeof(float));
  return count;
}

extern "C" uint8_t* factor_android_text_render(void* pointer, uint32_t foreground,
                                                 uint32_t background, int selection_start,
                                                 int selection_end, uint32_t selection_color,
                                                 int* width, int* height) {
  if (!pointer || !width || !height) return nullptr;
  uint8_t* result = nullptr;
  int bitmap_width = 0;
  int bitmap_height = 0;
  factor_android_dispatch_java([&](JNIEnv* env) {
    jobject bitmap = env->CallObjectMethod(static_cast<text*>(pointer)->object, api.render,
        foreground, background, selection_start, selection_end, selection_color);
    if (clear_exception(env) || !bitmap) return;
    AndroidBitmapInfo info{};
    void* pixels = nullptr;
    if (AndroidBitmap_getInfo(env, bitmap, &info) == ANDROID_BITMAP_RESULT_SUCCESS &&
        info.format == ANDROID_BITMAP_FORMAT_RGBA_8888 &&
        AndroidBitmap_lockPixels(env, bitmap, &pixels) == ANDROID_BITMAP_RESULT_SUCCESS) {
      const size_t bytes = static_cast<size_t>(info.width) * info.height * 4;
      result = static_cast<uint8_t*>(malloc(bytes));
      if (result) for (uint32_t y = 0; y < info.height; ++y)
        memcpy(result + static_cast<size_t>(y) * info.width * 4,
               static_cast<uint8_t*>(pixels) + static_cast<size_t>(y) * info.stride,
               static_cast<size_t>(info.width) * 4);
      AndroidBitmap_unlockPixels(env, bitmap);
      bitmap_width = info.width;
      bitmap_height = info.height;
    }
    env->DeleteLocalRef(bitmap);
  });
  *width = bitmap_width;
  *height = bitmap_height;
  return result;
}
