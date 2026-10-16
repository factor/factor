#pragma once

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

struct factor_android_text_metrics {
  float width, ascent, descent, height, leading, cap_height, x_height;
};

void* factor_android_text_create(const uint8_t* text, size_t length, const char* family,
                                 float size, int bold, int italic);
void factor_android_text_destroy(void* text);
int factor_android_text_metrics(void* text,
                                struct factor_android_text_metrics* metrics);
float factor_android_text_offset_x(void* text, int codepoint);
int factor_android_text_x_offset(void* text, float x);
int factor_android_text_selection_spans(void* text, int start, int end,
                                        float* spans, int capacity);
uint8_t* factor_android_text_render(void* text, uint32_t foreground,
                                    uint32_t background, int selection_start,
                                    int selection_end, uint32_t selection_color,
                                    int* width, int* height);

#ifdef __cplusplus
}
#endif
