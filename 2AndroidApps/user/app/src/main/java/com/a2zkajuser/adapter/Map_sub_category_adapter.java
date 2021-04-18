package com.a2zkajuser.adapter;

import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.Animation;
import android.view.animation.AnimationUtils;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.a2zkajuser.R;
import com.a2zkajuser.pojo.CategoryDetailPojo;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

/**
 * Created by user145 on 2/21/2017.
 */
public class Map_sub_category_adapter extends BaseAdapter {

    private ArrayList<CategoryDetailPojo> data;
    private LayoutInflater mInflater;
    private Context context;
    private int lastPosition = -1;

    public Map_sub_category_adapter(Context c, ArrayList<CategoryDetailPojo> d) {
        context = c;
        mInflater = LayoutInflater.from(context);
        data = d;
    }

    @Override
    public int getCount() {
        return data.size();
    }

    @Override
    public Object getItem(int position) {
        return position;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }


    public class ViewHolder {
        private TextView title;
        private ImageView image;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder holder;
        if (convertView == null) {
            view = mInflater.inflate(R.layout.map_sub_category_list_item, parent, false);
            holder = new ViewHolder();
            holder.title = (TextView) view.findViewById(R.id.sub_category_text);
            holder.image = (ImageView) view.findViewById(R.id.sub_category_image);
            view.setTag(holder);
        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }

        if (data.get(position).isCategorySelected()) {
            holder.title.setTextColor(Color.parseColor("#000000"));
            Picasso.with(context).load(data.get(position).getIcon_normal())
                    .error(R.drawable.placeholder_icon)
                    .placeholder(R.drawable.placeholder_icon).memoryPolicy(MemoryPolicy.NO_CACHE).into(holder.image);
        }
        else{
            holder.title.setTextColor(Color.parseColor("#000000"));
            Picasso.with(context).load(data.get(position).getCat_image())
                    .error(R.drawable.placeholder_icon)
                    .placeholder(R.drawable.placeholder_icon).memoryPolicy(MemoryPolicy.NO_CACHE).into(holder.image);
        }

        String title=data.get(position).getCat_name();
        holder.title.setText(data.get(position).getCat_name());
        Animation animation = AnimationUtils.loadAnimation(context, (position > lastPosition) ? R.anim.up_from_bottom : R.anim.down_from_top);
        view.startAnimation(animation);
        lastPosition = position;

        Animation animFadeOut = AnimationUtils.loadAnimation(context,R.anim.fade_in);
        holder.title.startAnimation(animFadeOut);

        return view;
    }
}
