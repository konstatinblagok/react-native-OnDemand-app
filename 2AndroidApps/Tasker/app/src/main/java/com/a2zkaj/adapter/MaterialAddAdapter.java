package com.a2zkaj.adapter;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.TextView;

import com.a2zkaj.Pojo.Addmaterialpojo;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.Utils.onItemRemoveClickListener;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.R;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by user145 on 3/15/2017.
 */
public class MaterialAddAdapter extends BaseAdapter {
    Context myContext;
    ArrayList<String> myListItems;
    private LayoutInflater mInflater;
    private ListView myListview;
    private CheckBox myCheckBox;
    private String myToolName = "";
    ArrayList<Addmaterialpojo> item_add;
    private ArrayList<EditText> tool_item = new ArrayList<EditText>();
    private ArrayList<EditText> tool_cost = new ArrayList<EditText>();
    private onItemRemoveClickListener onClickListener = null;
    SessionManager session;
    private String myCurrencySymbol="";

    public MaterialAddAdapter(Context aContext, ArrayList<String> listItems, ListView aList, CheckBox aBox, ArrayList<Addmaterialpojo> item_add) {
        this.myContext = aContext;
        this.myListItems = listItems;
        this.myListview = aList;
        this.myCheckBox = aBox;
        this.item_add=item_add;
        mInflater = LayoutInflater.from(myContext);
        session = new SessionManager(myContext);
    }

    @Override
    public int getCount() {
        return myListItems.size();
    }

    @Override
    public Object getItem(int i) {
        return i;
    }

    @Override
    public long getItemId(int i) {
        return i;
    }

    public ArrayList<EditText> getToolname() {
        return tool_item;
    }

    public ArrayList<EditText> getTool_cost() {
        return tool_cost;
    }

    public class ViewHolder {
        private ImageButton aCloseBTN;
        EditText edittext_tools, Edittext_cost;
        TextView amount_symbol;
    }

    private void updateInfo(ArrayList<String> aListItems) {
        this.myListItems = aListItems;
        notifyDataSetChanged();
    }

    @Override
    public View getView(final int aPosition, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {

            convertView = mInflater.inflate(R.layout.material_add_layout, parent, false);
            holder = new ViewHolder();
            holder.aCloseBTN = (ImageButton) convertView.findViewById(R.id.material_add_layout_BTN_item2);
            holder.edittext_tools = (EditText) convertView.findViewById(R.id.material_add_layout_ET_item1);
            holder.Edittext_cost = (EditText) convertView.findViewById(R.id.material_add_layout_ET_item2);
            holder.amount_symbol=(TextView)convertView.findViewById(R.id.amount_symbol);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }
        tool_item.clear();
        tool_cost.clear();
        tool_item.add(holder.edittext_tools);
        tool_cost.add(holder.Edittext_cost);

//        holder.edittext_tools.addTextChangedListener(new Textchange());
//        holder.Edittext_cost.addTextChangedListener(new Costchange());

        HashMap<String, String> aAmountMap = session.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);
        holder.amount_symbol.setText(myCurrencySymbol);

        holder.aCloseBTN.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {


                if (myListItems.size() == 0) {
                    return;
                }

                if (aPosition == 0) {
                    myListItems.clear();
                    item_add.clear();
                    Log.e("ArraySize", String.valueOf(item_add.size()));
                    tool_item.clear();
                    tool_cost.clear();
                    MyJobs_OnGoingDetailPage.item_add_bollean=true;
                    notifyDataSetChanged();
                    myCheckBox.setChecked(false);
                } else {
                    myListItems.remove(aPosition - 1);
                    item_add.remove(item_add.size() -1);
                    Log.e("ArraySize", String.valueOf(item_add.size()));
                    tool_item.clear();
                    tool_cost.clear();
                    MyJobs_OnGoingDetailPage.item_add_bollean=true;
                    //  MyJobs_OnGoingDetailPage.item_add.remove((MyJobs_OnGoingDetailPage.item_add.size())-1);
                    notifyDataSetChanged();
                    updateInfo(myListItems);
                    MyJobs_OnGoingDetailPage.UpdateListview();
                }

                if (onClickListener != null) {
                    onClickListener.onRemoveListener(aPosition);
                }


            }
        });
        return convertView;
    }



    }



