package com.a2zkaj.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RatingBar;
import android.widget.TextView;

import com.a2zkaj.Pojo.Reviwes_Pojo;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user88 on 1/7/2016.
 */
public class Reviwes_Adapter extends BaseAdapter {
    private ArrayList<Reviwes_Pojo> data;
    private LayoutInflater mInflater;
    private Activity context;
    private String check;
    public String Srating="";

    public Reviwes_Adapter(Activity c, ArrayList<Reviwes_Pojo> d) {
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


    public class ViewHolder {
        private TextView rating_desc_text;
        private RatingBar rating;

    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {

        View view;
        ViewHolder holder;

        if (convertView == null) {
            view = mInflater.inflate(R.layout.ratings_page_single, parent, false);
            holder = new ViewHolder();
            holder.rating_desc_text = (TextView) view.findViewById(R.id.rating_desc);
            holder.rating = (RatingBar) view.findViewById(R.id.rating_behaviour_rating_bar);

            view.setTag(holder);
        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }

        holder.rating_desc_text.setText(data.get(position).getOptions_title());

        holder.rating.setOnRatingBarChangeListener(new RatingBar.OnRatingBarChangeListener() {
            @Override
            public void onRatingChanged(RatingBar ratingBar, float rating, boolean fromUser) {
                Srating = String.valueOf(rating);
                data.get(position).setRatings_count(Srating);

            }
        });


        return view;
    }
}
