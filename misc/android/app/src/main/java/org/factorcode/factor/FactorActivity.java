package org.factorcode.factor;

import android.app.NativeActivity;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.InputType;
import android.view.View;
import android.view.ViewGroup;
import android.view.KeyCharacterMap;
import android.view.inputmethod.BaseInputConnection;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputConnection;
import android.view.inputmethod.InputMethodManager;

public final class FactorActivity extends NativeActivity {
    static { System.loadLibrary("factor-android"); }

    private InputView inputView;

    private static native void nativeCommitText(String text);
    private static native void nativeDeleteBackward(int count);
    private static native void nativeInitializeText(Class<?> type);

    @Override protected void onCreate(Bundle state) {
        super.onCreate(state);
        nativeInitializeText(FactorText.class);
        inputView = new InputView(this);
        addContentView(inputView, new ViewGroup.LayoutParams(1, 1));
        inputView.requestFocus();
    }

    public void setKeyboardVisible(final boolean visible) {
        runOnUiThread(() -> {
            InputMethodManager manager = (InputMethodManager)
                    getSystemService(Context.INPUT_METHOD_SERVICE);
            if (visible) {
                inputView.requestFocus();
                manager.showSoftInput(inputView, InputMethodManager.SHOW_IMPLICIT);
            } else {
                manager.hideSoftInputFromWindow(inputView.getWindowToken(), 0);
            }
        });
    }

    public void openUrl(String url) {
        runOnUiThread(() -> startActivity(new Intent(Intent.ACTION_VIEW,
                                                     Uri.parse(url))));
    }

    public int keyCharacter(int device, int code, int modifiers) {
        int character = KeyCharacterMap.load(device).get(code, modifiers);
        if ((character & KeyCharacterMap.COMBINING_ACCENT) != 0)
            character &= KeyCharacterMap.COMBINING_ACCENT_MASK;
        return character;
    }

    private static final class InputView extends View {
        InputView(Context context) {
            super(context);
            setFocusableInTouchMode(true);
        }

        @Override public boolean onCheckIsTextEditor() { return true; }

        @Override public InputConnection onCreateInputConnection(EditorInfo info) {
            info.inputType = InputType.TYPE_CLASS_TEXT |
                    InputType.TYPE_TEXT_FLAG_MULTI_LINE |
                    InputType.TYPE_TEXT_FLAG_NO_SUGGESTIONS;
            info.imeOptions = EditorInfo.IME_FLAG_NO_EXTRACT_UI;
            return new BaseInputConnection(this, false) {
                @Override public boolean commitText(CharSequence text, int cursor) {
                    FactorActivity.nativeCommitText(text.toString());
                    return super.commitText(text, cursor);
                }

                @Override public boolean deleteSurroundingText(int before, int after) {
                    if (before > 0) FactorActivity.nativeDeleteBackward(before);
                    return super.deleteSurroundingText(before, after);
                }
            };
        }
    }
}
