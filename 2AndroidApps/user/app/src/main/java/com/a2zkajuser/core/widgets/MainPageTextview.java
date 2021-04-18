package com.a2zkajuser.core.widgets;

import android.content.Context;
import android.graphics.Typeface;
import android.util.AttributeSet;
import android.widget.TextView;

/**
 * Created by user145 on 10/9/2017.
 */
public class MainPageTextview extends TextView {

    public MainPageTextview(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
        init();
    }

    public MainPageTextview(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public MainPageTextview(Context context) {
        super(context);
        init();
    }


    public void init() {
        Typeface tf = Typeface.createFromAsset(getContext().getAssets(), "fonts/Poppins-Medium.ttf");
        setTypeface(tf);
    }
}