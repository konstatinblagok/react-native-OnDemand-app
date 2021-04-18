package com.a2zkaj.adapter;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.a2zkaj.app.R;

/**
 * Created by CAS61 on 1/11/2017.
 */
public class CustomPagerAdapter extends PagerAdapter {
    private Context myContext;
    private int[] myImages;
    private LayoutInflater myLayoutInflater;
    private String[] myText;

    public CustomPagerAdapter(Context aContext, int[] aImageInt, String[] aText) {
        this.myContext = aContext;
        this.myImages = aImageInt;
        this.myText = aText;
        myLayoutInflater = (LayoutInflater) myContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
    }

    @Override
    public int getCount() {
        return myImages.length;
    }

    @Override
    public boolean isViewFromObject(View view, Object object) {
        return view.equals(object);
    }

    @Override
    public Object instantiateItem(ViewGroup container, int position) {
        View itemView = myLayoutInflater.inflate(R.layout.layout_inflate_pager_list_item, container, false);

        ImageView imageView = (ImageView) itemView.findViewById(R.id.layout_inflate_pager_list_item_IMG);
        TextView aTxtVw = (TextView) itemView.findViewById(R.id.layout_inflate_pager_list_item_TXT);

        imageView.setImageResource(myImages[position]);
        aTxtVw.setText(myText[position]);
        container.addView(itemView);

        return itemView;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }
}
