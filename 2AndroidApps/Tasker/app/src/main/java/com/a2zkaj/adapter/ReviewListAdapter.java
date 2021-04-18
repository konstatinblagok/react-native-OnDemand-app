package com.a2zkaj.adapter;

import android.app.Activity;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RatingBar;

import com.a2zkaj.Pojo.ReviewPojoInfo;
import com.a2zkaj.app.R;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

import core.Widgets.CustomTextView;
import core.Widgets.RoundedImageView;

/**
 * Created by user145 on 2/14/2017.
 */
public class ReviewListAdapter extends BaseAdapter {
    private LayoutInflater mInflater;
    private Context myContext;
    private ArrayList<ReviewPojoInfo> myReviewInfoList;
    private Activity context;

    public ReviewListAdapter(Context aContext, ArrayList<ReviewPojoInfo> aReviewInfoList) {
        this.myContext = aContext;
        this.myReviewInfoList = aReviewInfoList;
        mInflater = LayoutInflater.from(myContext);
    }


    @Override
    public int getCount() {
        return myReviewInfoList.size();
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
        private CustomTextView aUserName, aJobIdTXT, aUserFeedback, aViewImage, aReviewDate, aCategoryTXT;
        private RatingBar aRatingBar;
        private RoundedImageView aUserimage;
        private String aReviewImage;

    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        com.a2zkaj.adapter.ReviewListAdapter.ViewHolder holder;

        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.layout_inflate_review_list, parent, false);
            holder = new ReviewListAdapter.ViewHolder();
            holder.aUserName = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_name);
            holder.aJobIdTXT = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_Jobid);
            holder.aUserFeedback = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_comments);
            holder.aViewImage = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_viewimage);
            holder.aReviewDate = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_time);
            holder.aUserimage = (RoundedImageView) convertView.findViewById(R.id.layout_inflate_review_list_item_IMG_profile);
            holder.aRatingBar = (RatingBar) convertView.findViewById(R.id.layout_inflate_review_list_item_RGB);
            holder.aCategoryTXT = (CustomTextView) convertView.findViewById(R.id.layout_inflate_review_list_item_TXT_category);
            convertView.setTag(holder);
        } else {
            holder = (ReviewListAdapter.ViewHolder) convertView.getTag();
        }

        holder.aUserName.setText(myReviewInfoList.get(position).getReviewUser());
        holder.aJobIdTXT.setText(myReviewInfoList.get(position).getReviewBookingId() + " - ");
        holder.aCategoryTXT.setText(myReviewInfoList.get(position).getReviewCategory());
        holder.aUserFeedback.setText(myReviewInfoList.get(position).getReviewComments());
        holder.aRatingBar.setRating(Float.parseFloat(myReviewInfoList.get(position).getReviewRating()));
        holder.aReviewDate.setText(myReviewInfoList.get(position).getReviewDate());
        holder.aReviewImage = (myReviewInfoList.get(position).getUserImage());
        Picasso.with(context).load(String.valueOf((myReviewInfoList.get(position).getUserImage())))
                .placeholder(R.drawable.nouserimg).into(holder.aUserimage);
        if ((myReviewInfoList.get(position).getReviewImage()).equalsIgnoreCase("")) {
            holder.aViewImage.setVisibility(View.INVISIBLE);
        } else {
            holder.aViewImage.setVisibility(View.VISIBLE);
        }
        return convertView;
    }
}
