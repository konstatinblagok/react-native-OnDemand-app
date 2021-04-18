package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.a2zkaj.Pojo.ParentCategorypojo;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user145 on 5/30/2017.
 */
public class ParentCategoryAdapter extends BaseAdapter {
    private ArrayList<ParentCategorypojo> parentCategorypojoArrayList;
    private Context myContext;

    public ParentCategoryAdapter(Context aContext, ArrayList<ParentCategorypojo> parentCat_List) {
        this.myContext = aContext;
        this.parentCategorypojoArrayList = parentCat_List;
    }


    public int getPositionForItem(String parentID) {
        int pos = 0;
        for (int i = 0; i < parentCategorypojoArrayList.size(); i++) {
            if (parentCategorypojoArrayList.get(i).getParentCategoryID().equalsIgnoreCase(parentID)) {
                pos = i;
                break;
            }
        }
        return pos;
    }

    @Override
    public int getCount() {
        return parentCategorypojoArrayList.size();
    }

    @Override
    public ParentCategorypojo getItem(int position) {
        return parentCategorypojoArrayList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }


   /* @Override
    public View getDropDownView(int position, View convertView, ViewGroup parent) {
        View v = null;
        v = super.getDropDownView(position, null, parent);
        int selectedItem = position;
        if (position == selectedItem) {

            v.setBackgroundColor(Color.BLUE);
        } else {
            // for other views
            v.setBackgroundColor(Color.WHITE);

        }
        return v;
    }*/


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        if (convertView == null) {
            LayoutInflater infalInflater = (LayoutInflater) myContext
                    .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
            convertView = infalInflater.inflate(R.layout.parent_category_list_items, null);

            TextView parentcategory_name = (TextView) convertView.findViewById(R.id.mainCategory_label_tv);

            // parentcategory_name.setCompoundDrawablesWithIntrinsicBounds(0, 0, R.drawable.spinner_arrow_ic, 0);

            parentcategory_name.setText(parentCategorypojoArrayList.get(position).getParentCategory_name());

        }


        return convertView;
    }
}
