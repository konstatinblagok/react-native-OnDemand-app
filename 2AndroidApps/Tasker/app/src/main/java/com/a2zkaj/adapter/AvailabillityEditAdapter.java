package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkaj.Pojo.AvailabilityEditPojo;
import com.a2zkaj.Pojo.Availabilitypojo;
import com.a2zkaj.Utils.SmoothCheckBox;
import com.a2zkaj.app.EditProfilePage;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user145 on 5/9/2017.
 */
public class AvailabillityEditAdapter extends BaseAdapter {

    private ArrayList<Availabilitypojo> data;
    private LayoutInflater mInflater;
    private Context context;
    private String checkbox_status1 = "";
    private String checkbox_status2 = "";

    ArrayList<AvailabilityEditPojo> newarray = new ArrayList<AvailabilityEditPojo>();

    public AvailabillityEditAdapter(Context c, ArrayList<Availabilitypojo> d) {
        context = c;
        mInflater = LayoutInflater.from(context);
        data = d;
    }

    @Override
    public int getCount() {
        return data.size();
    }

    @Override
    public Object getItem(int i) {
        return null;
    }

    @Override
    public long getItemId(int i) {
        return 0;
    }


    public class ViewHolder {
        public TextView day;
        public SmoothCheckBox checkBox1, checkBox2, checkBox3;
        public SmoothCheckBox checkbox;
        RelativeLayout update_layout;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        View view;
        final ViewHolder holder;
        if (convertView == null) {
            view = mInflater.inflate(R.layout.availability_edit_single, parent, false);
            holder = new ViewHolder();
            holder.day = (TextView) view.findViewById(R.id.days);
            holder.checkbox = (SmoothCheckBox) view.findViewById(R.id.check1);
            holder.checkBox2 = (SmoothCheckBox) view.findViewById(R.id.check2);
            holder.checkBox3 = (SmoothCheckBox) view.findViewById(R.id.check3);
            holder.update_layout = (RelativeLayout) view.findViewById(R.id.update_layout);
            view.setTag(holder);
        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();

        }

        String days = data.get(position).getDays();

        holder.day.setText(data.get(position).getDays());
        String mor = data.get(position).getMorning();

        if (mor.equalsIgnoreCase("true") || mor.equalsIgnoreCase("1")) {
            holder.checkbox.setChecked(true);
        } else {
            holder.checkbox.setChecked(false);

        }
        String after = data.get(position).getAfternoon();
        if (after.equalsIgnoreCase("true") || after.equalsIgnoreCase("1")) {
            holder.checkBox2.setChecked(true);

        } else {
            holder.checkBox2.setChecked(false);
        }
        String eve = data.get(position).getEvening();
        if (eve.equalsIgnoreCase("true") || eve.equalsIgnoreCase("1")) {
            holder.checkBox3.setChecked(true);
        } else {
            holder.checkBox3.setChecked(false);

        }

        if (position == data.size() - 1) {
            holder.update_layout.setVisibility(View.VISIBLE);
        } else {
            holder.update_layout.setVisibility(View.GONE);
        }



        holder.checkbox.setOnClickListener(new CheckBoxClick(position,holder));
        holder.checkBox2.setOnClickListener(new CheckBoxClick2(position,holder));
        holder.checkBox3.setOnClickListener(new CheckBoxClick3(position,holder));


        //--------------------------------Update Button Click----------------------------
        holder.update_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                  newarray.clear();
                 for(int i=0;i<data.size();i++){

                     AvailabilityEditPojo pojo=new AvailabilityEditPojo();
                     pojo.setDays(data.get(i).getDays());
                     if(data.get(i).getMorning().equalsIgnoreCase("true")){
                         pojo.setMorning("1");
                     }
                     else{
                         pojo.setMorning("0");
                     }

                     if(data.get(i).getAfternoon().equalsIgnoreCase("true")){
                         pojo.setAfternoon("1");
                     }
                     else{
                         pojo.setAfternoon("0");
                     }

                     if(data.get(i).getEvening().equalsIgnoreCase("true")){
                         pojo.setEvening("1");
                     }
                     else{
                         pojo.setEvening("0");
                     }

                     newarray.add(pojo);
                     System.out.println("working_days[" + i + "][day]"+ "," + data.get(i).getDays());
                     System.out.println("working_days[" + i + "][hour]"+ "," + data.get(i).getMorning());
                     System.out.println("working_days[" + i + "][hour]"+ "," + data.get(i).getAfternoon());
                     System.out.println("working_days[" + i + "][hour]"+ "," + data.get(i).getEvening());
                 }

                SendtoEditableclass(newarray);
            }
        });

        return view;
    }

    private class CheckBoxClick implements View.OnClickListener {
        int position = 0;
        ViewHolder holder;

        private CheckBoxClick(int position,ViewHolder holder) {
            this.position = position;
            this.holder=holder;
        }

        @Override
        public void onClick(View v) {
            boolean s=holder.checkbox.isChecked();
            if(s){
                holder.checkbox.setChecked(false,false);
                String status= String.valueOf(s);
                data.get(position).setMorning("false");
                notifyDataSetChanged();
            }
            else{
                holder.checkbox.setChecked(true,true);
                String status= String.valueOf(s);
                data.get(position).setMorning("true");
                notifyDataSetChanged();
            }

        }
    }

    private class CheckBoxClick2 implements View.OnClickListener {
        int position = 0;
        ViewHolder holder;
        private CheckBoxClick2(int position,ViewHolder holder) {
            this.position = position;
            this.holder=holder;
            System.out.println("Check Status--------" + " " + checkbox_status2);
        }

        @Override
        public void onClick(View v) {
            boolean s=holder.checkBox2.isChecked();
            if(s){
                holder.checkBox2.setChecked(false,false);
                String status= String.valueOf(s);
                data.get(position).setAfternoon("false");
                notifyDataSetChanged();
            }
            else{
                holder.checkBox2.setChecked(true,true);
                String status= String.valueOf(s);
                data.get(position).setAfternoon("true");
                notifyDataSetChanged();
            }
        }
    }

    private class CheckBoxClick3 implements View.OnClickListener {
        int position = 0;
        ViewHolder holder;
        private CheckBoxClick3(int position,ViewHolder holder) {
            this.position = position;
            this.holder=holder;
        }
        @Override
        public void onClick(View v) {
            boolean s=holder.checkBox3.isChecked();
            if(s){
                holder.checkBox3.setChecked(false,false);
                String status= String.valueOf(s);
                data.get(position).setEvening("false");
                notifyDataSetChanged();
            }
            else{
                holder.checkBox3.setChecked(true,true);
                String status= String.valueOf(s);
                data.get(position).setEvening("true");
                notifyDataSetChanged();
            }
        }
    }
    public void SendtoEditableclass(ArrayList<AvailabilityEditPojo> arrayList){

        System.out.println("-----Array Size---------" + arrayList.size());
        EditProfilePage.EditAvailability(context,arrayList);


    }
}
