package com.a2zkaj.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkaj.Pojo.WorkFlow_Pojo;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user88 on 1/8/2016.
 */
public class JobWorkFlow_Adapter extends BaseAdapter {

    private ArrayList<WorkFlow_Pojo> data;
    private LayoutInflater mInflater;
    private Activity context;

    public JobWorkFlow_Adapter(Activity c, ArrayList<WorkFlow_Pojo> d) {
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
        private TextView Tv_workflow_job_title,Tv_workflow_job_date,Tv_workflow_time;

        private RelativeLayout Rl_workflow_date_time_layout;

        private ImageView Img_Check_icon,Img_Uncheck_icon;

    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder holder;
        if (convertView == null) {
            view = mInflater.inflate(R.layout.workflow_single_layout, parent, false);
            holder = new ViewHolder();
            holder.Tv_workflow_job_title = (TextView) view.findViewById(R.id.workflow_job_titleTv);
            holder.Tv_workflow_job_date = (TextView) view.findViewById(R.id.workflow_date_Tv);
            holder.Tv_workflow_time = (TextView) view.findViewById(R.id.workflow_time_Tv);
            holder.Rl_workflow_date_time_layout = (RelativeLayout)view.findViewById(R.id.layout_workflow_date_time);
            holder.Img_Check_icon = (ImageView)view.findViewById(R.id.workflow_checks_icon);


            view.setTag(holder);

        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }
           holder.Tv_workflow_job_title.setText(data.get(position).getJob_title());
           holder.Tv_workflow_job_date.setText(data.get(position).getJob_date());
           holder.Tv_workflow_time.setText(data.get(position).getJob_time());

//---------------------------------visible and invisible for date-----------------
      /*  if (!data.get(position).getJob_date().equalsIgnoreCase("")&&!data.get(position).getJob_time().equalsIgnoreCase("")){
            holder.Rl_workflow_date_time_layout.setVisibility(View.VISIBLE);
        }else{
            holder.Rl_workflow_date_time_layout.setVisibility(View.INVISIBLE);
        }
*/

        if (data.get(position).getJob_date().length()>0&&data.get(position).getJob_time().length()>0){
            holder.Rl_workflow_date_time_layout.setVisibility(View.VISIBLE);
        }else{
            holder.Rl_workflow_date_time_layout.setVisibility(View.INVISIBLE);
        }


       if (data.get(position).getJobs_check().equalsIgnoreCase("0")){
            holder.Img_Check_icon.setVisibility(View.VISIBLE);

        }else{
            holder.Img_Check_icon.setImageResource(R.drawable.workflow_check);
        }

        return view;
    }
}
