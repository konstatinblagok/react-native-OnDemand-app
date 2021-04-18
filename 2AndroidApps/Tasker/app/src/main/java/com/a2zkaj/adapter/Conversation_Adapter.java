package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkaj.Pojo.ChatPojo;
import com.a2zkaj.app.R;

import java.util.ArrayList;

/**
 * Created by user88 on 1/27/2016.
 */
public class Conversation_Adapter extends BaseAdapter {

    private ArrayList<ChatPojo> data;
    private LayoutInflater mInflater;
    private Context context;

    public Conversation_Adapter(Context c, ArrayList<ChatPojo> d) {
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

    @Override
    public int getViewTypeCount() {
        return 1;
    }


    public class ViewHolder {
        public ImageView messageStatus;
        private TextView Tv_rightMessage, Tv_rightTime;
        private TextView Tv_leftMessage, Tv_leftTime;
        private RelativeLayout Rl_left, Rl_right;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder holder;
        if (convertView == null) {
            view = mInflater.inflate(R.layout.conversation_page_single, parent, false);
            holder = new ViewHolder();
            holder.Tv_rightMessage = (TextView) view.findViewById(R.id.chat_right_message_text);
            holder.Tv_rightTime = (TextView) view.findViewById(R.id.chat_right_time_text);
            holder.Tv_leftMessage = (TextView) view.findViewById(R.id.chat_left_message_text);
            holder.Tv_leftTime = (TextView) view.findViewById(R.id.chat_left_time_text);
            holder.Rl_left = (RelativeLayout) view.findViewById(R.id.chat_left_main_layout);
            holder.Rl_right = (RelativeLayout) view.findViewById(R.id.chat_right_main_layout);

            view.setTag(holder);
        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }


        String type = data.get(position).getType();
        if (type.equalsIgnoreCase("SELF")) {

            holder.Rl_left.setVisibility(View.GONE);
            holder.Rl_right.setVisibility(View.VISIBLE);

            //holder1.Tv_rightMessage.setText(Emoji.replaceEmoji(data.get(position).getMessage(), holder1.Tv_rightMessage.getPaint().getFontMetricsInt(), AndroidUtilities.dp(16)));
            holder.Tv_rightMessage.setText(data.get(position).getMessage());
            holder.Tv_rightTime.setText(data.get(position).getTime());

        } else if (type.equalsIgnoreCase("OTHER")) {

            holder.Rl_left.setVisibility(View.VISIBLE);
            holder.Rl_right.setVisibility(View.GONE);

            // holder2.Tv_leftMessage.setText(Emoji.replaceEmoji(data.get(position).getMessage(), holder2.Tv_leftMessage.getPaint().getFontMetricsInt(), AndroidUtilities.dp(16)));
            holder.Tv_leftMessage.setText(data.get(position).getMessage());
            holder.Tv_leftTime.setText(data.get(position).getTime());
        }

        return view;
    }
}

