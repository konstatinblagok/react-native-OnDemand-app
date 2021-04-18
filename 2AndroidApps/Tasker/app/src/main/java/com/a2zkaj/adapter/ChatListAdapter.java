package com.a2zkaj.adapter;

import android.app.Activity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.TextView;

import com.a2zkaj.Pojo.ChatList_Pojo;
import com.a2zkaj.app.R;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

import java.util.ArrayList;

import core.Widgets.CircularImageView;

/**
 * Created by user88 on 2/3/2016.
 */
public class ChatListAdapter extends BaseAdapter {

    private ArrayList<ChatList_Pojo> data;
    private LayoutInflater mInflater;
    private Activity context;

    public ChatListAdapter(Activity c, ArrayList<ChatList_Pojo> d) {
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
        private TextView chatlist_plumbalNameTv,chatlist_messageTv,chatlist_messageTimeTv;
        private CircularImageView chatlist_profile_img;
    }


    @Override
    public View getView(int position, View convertView, ViewGroup parent) {

        View view;

        ViewHolder holder;

        if (convertView==null){

            view = mInflater.inflate(R.layout.chat_list_single,parent,false);
            holder = new ViewHolder();

            holder.chatlist_plumbalNameTv = (TextView)view.findViewById(R.id.chat_list_username);
            holder.chatlist_messageTv = (TextView)view.findViewById(R.id.chat_list_message);
            holder.chatlist_messageTimeTv = (TextView)view.findViewById(R.id.chatlist_messagetime);
            holder.chatlist_profile_img = (CircularImageView)view.findViewById(R.id.chat_list_profile_icon);
            view.setTag(holder);
        }else{
            view = convertView;
            holder = (ViewHolder)view.getTag();
        }
        holder.chatlist_plumbalNameTv.setText(data.get(position).getChatlist_name());
        holder.chatlist_messageTv.setText(data.get(position).getChatlist_message());
        holder.chatlist_messageTimeTv.setText(data.get(position).getChatlist_messageTime());

        Picasso.with(context).load(String.valueOf(data.get(position).getChatlist_image())).placeholder(R.drawable.nouserimg).memoryPolicy(MemoryPolicy.NO_CACHE).into(holder.chatlist_profile_img);

        return view;
    }
}
