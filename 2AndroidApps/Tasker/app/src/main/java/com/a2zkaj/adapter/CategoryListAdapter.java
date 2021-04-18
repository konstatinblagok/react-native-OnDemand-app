package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import com.a2zkaj.Pojo.UpdateCategorydatapojo;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user145 on 5/29/2017.
 */
public class CategoryListAdapter extends BaseAdapter {
    private ArrayList<UpdateCategorydatapojo> myCategorydatapojoArrayList;
    Context myContext;
    CategoryListItemClickListener listener;

    public CategoryListAdapter(Context context, ArrayList<UpdateCategorydatapojo> myCategorydatapojoArrayList) {
        this.myContext = context;
        this.myCategorydatapojoArrayList = myCategorydatapojoArrayList;
    }

    @Override
    public int getCount() {
        return myCategorydatapojoArrayList.size();
    }

    @Override
    public UpdateCategorydatapojo getItem(int position) {
        return myCategorydatapojoArrayList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(final int position, View convertView, ViewGroup parent) {
        LayoutInflater infalInflater = (LayoutInflater) myContext
                .getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        convertView = infalInflater.inflate(R.layout.edit_profile_category_list, null);

        TextView parentcategory_name = (TextView) convertView.findViewById(R.id.subCategory_list_item);
        final ImageView category_dlt = (ImageView) convertView.findViewById(R.id.categoryItem_dlt_imageView);
        final ImageView category_edit = (ImageView) convertView.findViewById(R.id.categoryItem_edit_imageView);

        category_dlt.setImageResource(R.drawable.ic_category_delete);

        category_edit.setImageResource(R.drawable.ic_category_edit);


        parentcategory_name.setText(myCategorydatapojoArrayList.get(position).getChildCategory());


        category_dlt.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                listener.onItemClick(category_dlt, position);
            }
        });

        category_edit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                listener.onItemClick(category_edit, position);
            }
        });

        return convertView;
    }

    public void setCategoryListItemClickListener(CategoryListItemClickListener listener) {
        this.listener = listener;
    }

    public void updateInfo(ArrayList<UpdateCategorydatapojo> aCategorydatapojoArrayList) {
        this.myCategorydatapojoArrayList = aCategorydatapojoArrayList;
        notifyDataSetChanged();
    }

    public interface CategoryListItemClickListener {
        void onItemClick(View view, int position);
    }


}
