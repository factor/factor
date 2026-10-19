package org.factorcode.factor;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.graphics.Region;
import android.graphics.RegionIterator;
import android.graphics.Typeface;
import android.text.Layout;
import android.text.StaticLayout;
import android.text.TextPaint;
import java.util.ArrayList;
import java.util.Collections;

/** Small public-API-only text service used by Factor's native UI thread. */
public final class FactorText {
    private final String text;
    private final TextPaint paint;
    private final StaticLayout layout;
    private final int width;
    private final int height;

    public FactorText(String text, String family, float size, boolean bold,
                      boolean italic) {
        this.text = text;
        paint = new TextPaint(Paint.ANTI_ALIAS_FLAG | Paint.SUBPIXEL_TEXT_FLAG);
        int style = (bold ? Typeface.BOLD : 0) | (italic ? Typeface.ITALIC : 0);
        paint.setTypeface(Typeface.create(family, style));
        paint.setTextSize(size);
        width = Math.max(1, (int)Math.ceil(paint.measureText(text)) + 2);
        layout = new StaticLayout(text, paint, width, Layout.Alignment.ALIGN_NORMAL,
                                  1.0f, 0.0f, false);
        height = Math.max(1, layout.getHeight());
    }

    public float[] metrics() {
        Paint.FontMetrics metrics = paint.getFontMetrics();
        Rect bounds = new Rect();
        paint.getTextBounds("H", 0, 1, bounds);
        float capHeight = bounds.height();
        paint.getTextBounds("x", 0, 1, bounds);
        float xHeight = bounds.height();
        float textWidth = text.isEmpty() ? 0.0f : paint.measureText(text);
        return new float[] { textWidth, -metrics.ascent, metrics.descent,
                             -metrics.ascent + metrics.descent, metrics.leading,
                             capHeight, xHeight };
    }

    // Factor positions count code points; Android layouts count UTF-16 units.
    private int utf16Offset(int codepoints) {
        int count = Math.max(0, Math.min(codepoints, text.codePointCount(0, text.length())));
        return text.offsetByCodePoints(0, count);
    }

    public float offsetX(int codepoints) {
        return layout.getPrimaryHorizontal(utf16Offset(codepoints));
    }

    public int xOffset(float x) {
        int utf16 = layout.getOffsetForHorizontal(0, x);
        return text.codePointCount(0, utf16);
    }

    public float[] selectionSpans(int startCodepoint, int endCodepoint) {
        int start = utf16Offset(Math.min(startCodepoint, endCodepoint));
        int end = utf16Offset(Math.max(startCodepoint, endCodepoint));
        if (start == end) {
            float x = layout.getPrimaryHorizontal(start);
            return new float[] { x, x };
        }
        Path path = new Path();
        layout.getSelectionPath(start, end, path);
        Region region = new Region();
        region.setPath(path, new Region(0, 0, width, height));
        ArrayList<float[]> spans = new ArrayList<>();
        RegionIterator iterator = new RegionIterator(region);
        Rect rectangle = new Rect();
        while (iterator.next(rectangle))
            spans.add(new float[] { rectangle.left, rectangle.right });
        Collections.sort(spans, (first, second) -> Float.compare(first[0], second[0]));
        ArrayList<float[]> merged = new ArrayList<>();
        for (float[] span : spans) {
            float[] previous = merged.isEmpty() ? null : merged.get(merged.size() - 1);
            if (previous != null && span[0] <= previous[1]) {
                previous[1] = Math.max(span[1], previous[1]);
            } else {
                merged.add(span);
            }
        }
        float[] result = new float[merged.size() * 2];
        for (int i = 0; i < merged.size(); ++i) {
            result[2 * i] = merged.get(i)[0];
            result[2 * i + 1] = merged.get(i)[1];
        }
        return result;
    }

    public Bitmap render(int foreground, int background, int selectionStart,
                         int selectionEnd, int selectionColor) {
        Bitmap bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawColor(background);
        if (selectionStart >= 0) {
            Paint selection = new Paint();
            selection.setColor(selectionColor);
            int start = utf16Offset(Math.min(selectionStart, selectionEnd));
            int end = utf16Offset(Math.max(selectionStart, selectionEnd));
            Path path = new Path();
            layout.getSelectionPath(start, end, path);
            canvas.drawPath(path, selection);
        }
        paint.setColor(foreground);
        layout.draw(canvas);
        return bitmap;
    }
}
