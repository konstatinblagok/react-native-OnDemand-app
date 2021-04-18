package com.a2zkajuser.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.a2zkajuser.R;
import com.a2zkajuser.core.widgets.CustomTextView;
import com.a2zkajuser.pojo.TransactionPojoInfo;
import com.a2zkajuser.utils.CurrencySymbolConverter;
import com.a2zkajuser.utils.SessionManager;

import java.util.ArrayList;
import java.util.HashMap;

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
        private CustomTextView aJobIdTXT, aPriceTXT, aCategoryTXT;
        TextView date;
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
            holder.date = (TextView)convertView.findViewById(R.id.date);

            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        HashMap<String, String> aAmountMap = session.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);

        holder.aJobIdTXT.setText(myTransactionInfoList.get(position).getTransactionJobId());
        holder.aCategoryTXT.setText(myTransactionInfoList.get(position).getTransactionCategoryName());
        holder.aPriceTXT.setText(myCurrencySymbol+myTransactionInfoList.get(position).getTransactionTotalAmount());
        holder.date.setText(myTransactionInfoList.get(position).getTransactionDate() + "  " + myTransactionInfoList.get(position).getTransactionTime());
        return convertView;
    }
}
