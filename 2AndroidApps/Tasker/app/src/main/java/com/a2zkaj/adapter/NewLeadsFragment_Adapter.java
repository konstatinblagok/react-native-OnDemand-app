package com.a2zkaj.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.a2zkaj.Pojo.NewLeadsPojo;
import com.a2zkaj.app.R;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

import core.Widgets.RoundedImageView;

/**
 * Created by user88 on 12/15/2015.
 */
public class NewLeadsFragment_Adapter extends BaseAdapter {

    private ArrayList<NewLeadsPojo> data;
    private LayoutInflater mInflater;
    private Activity context;

    public NewLeadsFragment_Adapter(Activity c, ArrayList<NewLeadsPojo> d) {
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
        private TextView newleads_location_Tv,newleads_timeand_date,Tv_newjob_status;
        private TextView newleads_orderidTv,newleads_username,newleads_jobtype;
        private RoundedImageView newleads_profile_img;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View view;
        ViewHolder holder;

        if (convertView==null)
        {
            view = mInflater.inflate(R.layout.newleads_fragment_single,parent,false);
            holder = new ViewHolder();

            holder.newleads_jobtype = (TextView)view.findViewById(R.id.newleads_job_type);
            holder.newleads_location_Tv = (TextView)view.findViewById(R.id.newkleads_locationTv);
            holder.newleads_timeand_date = (TextView)view.findViewById(R.id.newleads_jobtime);
            holder.newleads_username = (TextView)view.findViewById(R.id.newleads_username);
            holder.newleads_orderidTv = (TextView)view.findViewById(R.id.newleads_orderid);
            holder.newleads_profile_img = (RoundedImageView)view.findViewById(R.id.newleads_profileimg);
            holder.Tv_newjob_status  = (TextView)view.findViewById(R.id.new_Job_status);

            view.setTag(holder);

        }else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }


        holder.Tv_newjob_status.setText(data.get(position).getNewleads_jobstatus());
        holder.newleads_username.setText(data.get(position).getNewleads_user_name());
        holder.newleads_timeand_date.setText(data.get(position).getNewleads_jabtimeand_date());
        holder.newleads_jobtype.setText(data.get(position).getNewleads_category());
        holder.newleads_location_Tv.setText(data.get(position).getNewleads_location());
        holder.newleads_orderidTv.setText(data.get(position).getNewleads_order_id());

        Picasso.with(context).load(String.valueOf(data.get(position).getNewleads_user_image()))
                .placeholder(R.drawable.nouserimg).memoryPolicy(MemoryPolicy.NO_CACHE).into(holder.newleads_profile_img);

        return view;
    }


}
