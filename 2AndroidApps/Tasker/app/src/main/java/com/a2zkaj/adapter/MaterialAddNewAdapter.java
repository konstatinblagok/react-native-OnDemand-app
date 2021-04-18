package com.a2zkaj.adapter;

import android.content.Context;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.CheckBox;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import com.a2zkaj.Pojo.Addmaterialpojo;
import com.a2zkaj.Pojo.MaterialEditextValue;
import com.a2zkaj.Pojo.Materialcostsubmitpojo;
import com.a2zkaj.Utils.CurrencySymbolConverter;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.Utils.onItemRemoveClickListener;
import com.a2zkaj.app.MyJobs_OnGoingDetailPage;
import com.a2zkaj.app.R;

import java.util.ArrayList;
import java.util.HashMap;

/**
 * Created by user145 on 5/26/2017.
 */
public class MaterialAddNewAdapter extends BaseAdapter {
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
    private String myCurrencySymbol = "";
    ArrayList<MaterialEditextValue> materialarray = new ArrayList<MaterialEditextValue>();
    ArrayList<Materialcostsubmitpojo> submitarray = new ArrayList<Materialcostsubmitpojo>();
    public static boolean selectvalue = false;

    public MaterialAddNewAdapter(Context aContext, ArrayList<String> listItems, ListView aList, CheckBox aBox, ArrayList<Addmaterialpojo> item_add) {
        this.myContext = aContext;
        this.myListItems = listItems;
        this.myListview = aList;
        this.myCheckBox = aBox;
        this.item_add = item_add;
        mInflater = LayoutInflater.from(myContext);
        session = new SessionManager(myContext);
        selectvalue = false;
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
        RelativeLayout add_fields_layout;
        RelativeLayout bottom_layout;
        RelativeLayout cancel_layout;
        RelativeLayout add_one_layout;
    }

    private void updateInfo(ArrayList<String> aListItems, ArrayList<Addmaterialpojo> item_add) {
        this.myListItems = aListItems;
        this.item_add = item_add;
        notifyDataSetChanged();
    }

    @Override
    public View getView(final int aPosition, View convertView, ViewGroup parent) {
        final ViewHolder holder;
        if (convertView == null) {

            convertView = mInflater.inflate(R.layout.new_material_layout, parent, false);
            holder = new ViewHolder();
            holder.aCloseBTN = (ImageButton) convertView.findViewById(R.id.material_add_layout_BTN_item2);
            holder.edittext_tools = (EditText) convertView.findViewById(R.id.material_add_layout_ET_item1);
            holder.Edittext_cost = (EditText) convertView.findViewById(R.id.material_add_layout_ET_item2);
            holder.amount_symbol = (TextView) convertView.findViewById(R.id.amount_symbol);
            holder.add_fields_layout = (RelativeLayout) convertView.findViewById(R.id.add_fields_layout);
            holder.bottom_layout = (RelativeLayout) convertView.findViewById(R.id.bottom_layout);
            holder.cancel_layout = (RelativeLayout) convertView.findViewById(R.id.cancel_layout);
            holder.add_one_layout = (RelativeLayout) convertView.findViewById(R.id.add_one_layout);
            convertView.setTag(holder);
        } else {
            holder = (ViewHolder) convertView.getTag();
        }

        if (myListItems.size() > 0) {
            MyJobs_OnGoingDetailPage.aOKLAY.setVisibility(View.GONE);
            MyJobs_OnGoingDetailPage.aCancelLAY.setVisibility(View.GONE);
            holder.add_fields_layout.setVisibility(View.VISIBLE);
            holder.cancel_layout.setVisibility(View.VISIBLE);
            holder.add_one_layout.setVisibility(View.VISIBLE);
        }

        if (item_add.size() > 0) {
            String edit_tool = item_add.get(aPosition).getToolname();
            String edit_cost = item_add.get(aPosition).getToolcost();
            if (edit_tool.equalsIgnoreCase("name") && edit_cost.equalsIgnoreCase("cost")) {
                edit_tool = "";
                edit_cost = "";
            }
            try {
                holder.edittext_tools.setText(edit_tool);
                holder.edittext_tools.setCursorVisible(true);
                holder.Edittext_cost.setText(edit_cost);
                holder.Edittext_cost.setCursorVisible(true);
            } catch (IndexOutOfBoundsException e) {
                e.printStackTrace();
            }
        }

        holder.edittext_tools.setId(aPosition);
        holder.Edittext_cost.setId(aPosition);

        holder.edittext_tools.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                int tool_edit_pos = v.getId();
                holder.edittext_tools.addTextChangedListener(new Textchange(tool_edit_pos, holder));
            }
        });

        holder.Edittext_cost.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                int cost_edit_pos = v.getId();
                holder.Edittext_cost.addTextChangedListener(new Costchange(cost_edit_pos, holder));
            }
        });

        if (aPosition == myListItems.size() - 1) {
            holder.bottom_layout.setVisibility(View.VISIBLE);

        } else {
            holder.bottom_layout.setVisibility(View.GONE);
        }

        holder.add_fields_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!selectvalue) {
                    tool_item.add(holder.edittext_tools);
                    tool_cost.add(holder.Edittext_cost);
                    selectvalue = true;
                }

                Addmaterialpojo pojo = new Addmaterialpojo();
                pojo.setToolname("name");
                pojo.setToolcost("cost");
                item_add.add(pojo);
                myListItems.add("1");
                tool_item.add(holder.edittext_tools);
                tool_cost.add(holder.Edittext_cost);
                updateInfo(myListItems, item_add);
            }
        });

        holder.aCloseBTN.setOnClickListener(new ButtonClose(aPosition, holder));

        HashMap<String, String> aAmountMap = session.getWalletDetails();
        String aCurrencyCode = aAmountMap.get(SessionManager.KEY_CURRENCY_CODE);
        myCurrencySymbol = CurrencySymbolConverter.getCurrencySymbol(aCurrencyCode);
        holder.amount_symbol.setText(myCurrencySymbol);


        holder.add_one_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                submitarray.clear();
                int size = item_add.size();
                System.out.println("-----------Size---" + size);
                outerloop:
                for (int i = 0; i < item_add.size(); i++) {
                    Materialcostsubmitpojo pojo = new Materialcostsubmitpojo();
                    String toolname = item_add.get(i).getToolname();
                    if (toolname.equalsIgnoreCase("name") || toolname.equalsIgnoreCase("")) {
                        Toast.makeText(myContext, myContext.getResources().getString(R.string.meterial_add_new_enter_the_toolname), Toast.LENGTH_LONG).show();
                        break outerloop;
                    } else {
                        pojo.setToolname(toolname);
                    }
                    String toolcost = item_add.get(i).getToolcost();
                    if (toolcost.equalsIgnoreCase("cost") || toolcost.equalsIgnoreCase("")) {
                        Toast.makeText(myContext, myContext.getResources().getString(R.string.meterial_add_new_enter_the_toolcost), Toast.LENGTH_LONG).show();
                        break outerloop;
                    } else {
                        pojo.setToolcost(toolcost);
                        submitarray.add(pojo);
                    }
                    if (i == item_add.size() - 1) {
                        Submitmaterialfees(submitarray);
                        break outerloop;
                    }

                }
            }
        });


        holder.cancel_layout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (MyJobs_OnGoingDetailPage.moreAddressDialog != null) {
                    MyJobs_OnGoingDetailPage.moreAddressDialog.dismiss();
                }

            }
        });

        return convertView;
    }


    private class Textchange implements TextWatcher {

        int position = 0;
        ViewHolder holder;

        public Textchange(int aPosition, ViewHolder holder) {
            position = aPosition;
            this.holder = holder;
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {

        }

        @Override
        public void afterTextChanged(Editable s) {
            String toolname = holder.edittext_tools.getText().toString();
            item_add.get(position).setToolname(toolname);
        }
    }

    private class Costchange implements TextWatcher {
        int position = 0;
        ViewHolder holder;

        public Costchange(int aPosition, ViewHolder holder) {
            position = aPosition;
            this.holder = holder;
        }

        @Override
        public void beforeTextChanged(CharSequence s, int start, int count, int after) {

        }

        @Override
        public void onTextChanged(CharSequence s, int start, int before, int count) {

        }

        @Override
        public void afterTextChanged(Editable s) {
            String toolcost = holder.Edittext_cost.getText().toString();
            item_add.get(position).setToolcost(toolcost);
        }
    }

    private class ButtonClose implements View.OnClickListener {
        int position = 0;
        ViewHolder holder;

        public ButtonClose(int aPosition, ViewHolder holder) {
            position = aPosition;
            this.holder = holder;
        }

        @Override
        public void onClick(View v) {

//            int size=tool_item.size();
//            int size1=tool_cost.size();
//            tool_item.remove(position);
//            tool_cost.remove(position);
            if (position == myListItems.size() - 1) {
                MyJobs_OnGoingDetailPage.aOKLAY.setVisibility(View.VISIBLE);
                MyJobs_OnGoingDetailPage.aCancelLAY.setVisibility(View.VISIBLE);
                if (position == 0) {
                    MyJobs_OnGoingDetailPage.addmaterial.setChecked(false);
                }
                holder.add_fields_layout.setVisibility(View.GONE);
                holder.cancel_layout.setVisibility(View.GONE);
                holder.add_one_layout.setVisibility(View.GONE);
            }
            if (item_add.size() > 0) {
                item_add.remove(position);
                //  item_add.remove(item_add.size()-1);
            }

            if (myListItems.size() > 0) {
                myListItems.remove(position);
            }
            updateInfo(myListItems, item_add);
            // notifyDataSetChanged();

        }
    }


    private void Submitmaterialfees(ArrayList<Materialcostsubmitpojo> arrayList) {
        if (MyJobs_OnGoingDetailPage.moreAddressDialog != null) {
            MyJobs_OnGoingDetailPage.moreAddressDialog.dismiss();
        }

        System.out.println("-------------SubmitMaterialArrayFees--------------" + arrayList.size());
        MyJobs_OnGoingDetailPage.SubmitMaterialFees(arrayList, myContext);
    }
}



