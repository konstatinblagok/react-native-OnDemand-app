package com.a2zkaj.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.a2zkaj.Pojo.MissedLeads_Pojo;
import com.a2zkaj.app.R;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

import core.Widgets.RoundedImageView;

/**
 * Created by user88 on 12/15/2015.
 */
public class MissedLeadsFragment_Adapter extends BaseAdapter {
    private ArrayList<MissedLeads_Pojo> data;
    private LayoutInflater mInflater;
    private Activity context;

    public MissedLeadsFragment_Adapter(Activity c, ArrayList<MissedLeads_Pojo> d) {
        context = c;
        mInflater = LayoutInflater.from(context);
        data = d;
    }

    @Override
    public int getCount() {
        return  data.size();
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
        private TextView missedleads_location_Tv,missedleads_timeand_date,Tv_missed_job_status;
        private TextView missedleads_orderidTv,missedleads_username,missedleads_jobtype;
        private RoundedImageView missedleads_profile_img;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View view;
        ViewHolder holder;

        if (convertView==null) {
            view = mInflater.inflate(R.layout.missedleads_fragment_single, parent, false);
            holder = new ViewHolder();

            holder.missedleads_jobtype = (TextView)view.findViewById(R.id.missedleads_job_type);
            holder.missedleads_location_Tv = (TextView)view.findViewById(R.id.missedleads_locationTv);
            holder.missedleads_timeand_date = (TextView)view.findViewById(R.id.missedleads_jobtime);
            holder.missedleads_orderidTv = (TextView)view.findViewById(R.id.missedleads_orderid);
            holder.missedleads_username = (TextView)view.findViewById(R.id.missedleads_username);
            holder.missedleads_profile_img = (RoundedImageView)view.findViewById(R.id.missedleads_profileimg);
            holder.Tv_missed_job_status = (TextView)view.findViewById(R.id.missed_Job_status);


           view.setTag(holder);

        }else {
            view = convertView;
            holder = (ViewHolder)view.getTag();
        }

        holder.Tv_missed_job_status.setText(data.get(position).getMossedleads_jobstatus());
        holder.missedleads_username.setText(data.get(position).getMissedleads_user_name());
        holder.missedleads_jobtype.setText(data.get(position).getMissedleads_jobtype());
        holder.missedleads_location_Tv.setText(data.get(position).getMissedleads_location());
        holder.missedleads_orderidTv.setText(data.get(position).getMissedleads_order_id());
        holder.missedleads_timeand_date.setText(data.get(position).getMissedleads_jabtimeand_date());

        Picasso.with(context).load(String.valueOf(data.get(position).getMissedleads_user_image())).placeholder(R.drawable.nouserimg).memoryPolicy(MemoryPolicy.NO_CACHE).into(holder.missedleads_profile_img);


        return view;
    }
}
