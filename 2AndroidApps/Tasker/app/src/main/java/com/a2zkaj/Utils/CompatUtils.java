package com.a2zkaj.Utils;

import android.content.Context;

/**
 * Created by user145 on 5/9/2017.
 */
public class CompatUtils {
    public static int dp2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }
}