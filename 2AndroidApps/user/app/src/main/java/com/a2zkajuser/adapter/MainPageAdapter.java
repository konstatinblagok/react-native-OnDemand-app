package com.a2zkajuser.adapter;

import android.content.Context;
import android.support.v4.view.PagerAdapter;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.a2zkajuser.R;

/**
 * Created by user145 on 9/28/2017.
 */
public class MainPageAdapter extends PagerAdapter {
    private Context myContext;
    private int[] myImages;
    private LayoutInflater myLayoutInflater;
    private String[] myText;
    String[] title;
    String[] text;
    String[] text1;

    public MainPageAdapter(Context aContext, int[] aImageInt,String[] title,String[] text,String[] text1) {
        this.myContext = aContext;
        this.myImages = aImageInt;
        this.title=title;
        this.text=text;
        this.text1=text1;
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
        TextView titles=(TextView)itemView.findViewById(R.id.title);
        TextView texts1=(TextView)itemView.findViewById(R.id.text1);
        TextView texts2=(TextView)itemView.findViewById(R.id.text2);

        imageView.setImageResource(myImages[position]);
        titles.setText(text[position]);
        texts1.setText(text1[position]);
       // texts2.setText(text1[position]);
        container.addView(itemView);

        return itemView;
    }

    @Override
    public void destroyItem(ViewGroup container, int position, Object object) {
        container.removeView((View) object);
    }
}