package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;


import com.a2zkaj.Pojo.ProviderCategory;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.R;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by user145 on 10/4/2017.
 */
public class ProviderCategoryAdapter extends BaseAdapter {

    private ArrayList<ProviderCategory> cat_list_item;
    ArrayList<String> listItems;
    private LayoutInflater mInflater;
    private Context context;
    private SessionManager sessionManager;



    public ProviderCategoryAdapter(Context context, ArrayList<String> listItems, ArrayList<ProviderCategory> cat_list_item) {

        this.context=context;
        this.listItems=listItems;
        this.cat_list_item=cat_list_item;
        mInflater = LayoutInflater.from(context);
        sessionManager=new SessionManager(context);

    }

    @Override
    public int getCount() {
        return listItems.size();
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
     private TextView category;
     private TextView hourly_rate;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.provider_category_list, parent, false);
            holder = new ViewHolder();
            holder.category = (TextView) convertView.findViewById(R.id.category);
            holder.hourly_rate = (TextView) convertView.findViewById(R.id.hourly_rate);

            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        HashMap<String, String> aAmountMap = sessionManager.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        final String myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);

       if(cat_list_item.size()>position){

           holder.category.setText(cat_list_item.get(position).getCategory_name());
           holder.hourly_rate.setText(myCurrencySymbol+cat_list_item.get(position).getHourly_rate()+"/"+"hr");
       }


        return convertView;
    }
}