package org.factorcode.factor;

import android.app.Activity;
import android.app.Instrumentation;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.os.Bundle;
import android.util.Log;
import java.util.Arrays;

/** Runs in an Android app process with its real font and canvas services. */
public final class FactorTextTest extends Instrumentation {
    private static FactorText text(String value) {
        return new FactorText(value, "sans-serif", 30, false, false);
    }

    private static void check(boolean condition, String message) {
        if (!condition) throw new AssertionError(message);
    }

    private static Bitmap render(FactorText layout, int start, int end) {
        return layout.render(Color.BLACK, Color.WHITE, start, end, Color.RED);
    }

    private static void selectionStaysOnItsLine() {
        FactorText layout = text("   \n   ");
        Bitmap first = render(layout, 0, 3);
        Bitmap second = render(layout, 4, 7);
        try {
            int top = first.getHeight() / 4;
            int bottom = first.getHeight() * 3 / 4;
            check(first.getPixel(2, top) == Color.RED, "first line is selected");
            check(first.getPixel(2, bottom) == Color.WHITE,
                  "first-line selection must not paint the second line");
            check(second.getPixel(2, top) == Color.WHITE,
                  "second-line selection must not paint the first line");
            check(second.getPixel(2, bottom) == Color.RED, "second line is selected");
        } finally {
            first.recycle();
            second.recycle();
        }
    }

    private static void selectionRangesAreNormalized() {
        FactorText layout = text("abc אבג xyz");
        Bitmap forward = render(layout, 2, 7);
        Bitmap reversed = render(layout, 7, 2);
        Bitmap collapsed = render(layout, 2, 2);
        Bitmap plain = render(layout, -1, -1);
        try {
            check(forward.sameAs(reversed), "reversed selection has the same pixels");
            check(collapsed.sameAs(plain), "collapsed selection has no background");
            check(Arrays.equals(layout.selectionSpans(2, 7), layout.selectionSpans(7, 2)),
                  "reversed selection has the same spans");
        } finally {
            forward.recycle();
            reversed.recycle();
            collapsed.recycle();
            plain.recycle();
        }
    }

    private static void unicodeOffsetsUseCodePoints() {
        FactorText layout = text("A😀ב");
        check(layout.metrics().length == 7, "native metrics have seven fields");
        check(layout.offsetX(-10) == layout.offsetX(0), "negative offsets clamp");
        check(layout.offsetX(100) == layout.offsetX(3), "large offsets clamp");
        check(layout.xOffset(layout.offsetX(2)) == 2, "emoji counts as one code point");
        float[] caret = layout.selectionSpans(2, 2);
        check(caret.length == 2 && caret[0] == caret[1], "collapsed spans mark the caret");
        Bitmap empty = render(text(""), 0, 0);
        try {
            check(empty.getWidth() > 0 && empty.getHeight() > 0, "empty text is renderable");
        } finally {
            empty.recycle();
        }
    }

    @Override public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        start();
    }

    @Override public void onStart() {
        Bundle result = new Bundle();
        try {
            selectionStaysOnItsLine();
            selectionRangesAreNormalized();
            unicodeOffsetsUseCodePoints();
            result.putString("stream", "FactorText Java checks passed\n");
            finish(Activity.RESULT_OK, result);
        } catch (Throwable failure) {
            result.putString("stream", Log.getStackTraceString(failure));
            finish(Activity.RESULT_CANCELED, result);
        }
    }
}
