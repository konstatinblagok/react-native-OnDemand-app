package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;

import com.a2zkaj.Pojo.TransactionPojoInfo;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.R;

import java.util.ArrayList;
import java.util.HashMap;

import core.Widgets.CustomTextView;

/**
 * Created by user145 on 2/14/2017.
 */
public class TransactionListAdapter extends BaseAdapter {

    private Context myContext;
    private ArrayList<TransactionPojoInfo> myTransactionInfoList;
    private LayoutInflater mInflater;
    private String myCurrencySymbol="";
    SessionManager session;

    public TransactionListAdapter(Context aContext, ArrayList<TransactionPojoInfo> aTransactionInfoList) {
        this.myContext = aContext;
        this.myTransactionInfoList = aTransactionInfoList;
        mInflater = LayoutInflater.from(myContext);
        session = new SessionManager(myContext);
    }

    @Override
    public int getCount() {
        return myTransactionInfoList.size();
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
        private CustomTextView aJobIdTXT, aPriceTXT, aCategoryTXT,date_time_TV;
        private ImageView aTaskerIMG;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        ViewHolder holder;
        if (convertView == null) {
            convertView = mInflater.inflate(R.layout.layout_inflate_transaction_list_item, parent, false);
            holder = new ViewHolder();

            holder.aJobIdTXT = (CustomTextView) convertView.findViewById(R.id.layout_inflate_transaction_list_item_TXT_jobid);
            holder.aPriceTXT = (CustomTextView) convertView.findViewById(R.id.layout_inflate_transaction_list_item_TXT_price);
            holder.aCategoryTXT = (CustomTextView) convertView.findViewById(R.id.layout_inflate_transaction_list_item_TXT_category);
            holder.aTaskerIMG = (ImageView) convertView.findViewById(R.id.layout_inflate_transaction_list_item_IMG);
            holder.date_time_TV=(CustomTextView)convertView.findViewById(R.id.layout_inflate_transaction_date_time);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        HashMap<String, String> aAmountMap = session.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);

        holder.aJobIdTXT.setText(myTransactionInfoList.get(position).getTransactionJobId());
        holder.aCategoryTXT.setText(myTransactionInfoList.get(position).getTransactionCategoryName());
        holder.aPriceTXT.setText(myCurrencySymbol + myTransactionInfoList.get(position).getTransactionTotalAmount());
        holder.date_time_TV.setText(myTransactionInfoList.get(position).getDate() + ","+ myTransactionInfoList.get(position).getTime());
        return convertView;
    }
}
