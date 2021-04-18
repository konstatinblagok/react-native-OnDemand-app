package com.a2zkaj.adapter;

import android.content.Context;
import android.content.DialogInterface;
import android.support.v7.app.AlertDialog;
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
 * Casperon Technology on 1/29/2016.
 */
public class ChatAdapter extends BaseAdapter {

    private ArrayList<ChatPojo> data;
    private LayoutInflater mInflater;
    private Context context;

    public ChatAdapter(Context c, ArrayList<ChatPojo> d) {
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
        public ImageView messageStatus, avatar;
        private TextView Tv_rightMessage, Tv_rightTime, myRightTXTTime;
        private TextView Tv_leftMessage, Tv_leftTime, myLeftTXTTime;
        private RelativeLayout Rl_left, Rl_right;
        RelativeLayout warning;
        private ImageView mySeenStatusIMG;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        View view;
        ViewHolder holder;
        if (convertView == null) {
            view = mInflater.inflate(R.layout.chat_single, parent, false);
            holder = new ViewHolder();
            holder.avatar = (ImageView) view.findViewById(R.id.imageview_left);
            holder.Tv_rightMessage = (TextView) view.findViewById(R.id.chat_right_message_text);
            //holder.Tv_rightTime = (TextView) view.findViewById(R.id.chat_right_time_text);
            holder.Tv_leftMessage = (TextView) view.findViewById(R.id.chat_left_message_text);
            //holder.Tv_leftTime = (TextView) view.findViewById(R.id.chat_left_time_text);
            holder.Rl_left = (RelativeLayout) view.findViewById(R.id.chat_left_main_layout);
            holder.Rl_right = (RelativeLayout) view.findViewById(R.id.chat_right_main_layout);
            holder.warning=(RelativeLayout)view.findViewById(R.id.warning);
            holder.myRightTXTTime = (TextView) view.findViewById(R.id.chat_right_TXT_time);
            holder.mySeenStatusIMG = (ImageView) view.findViewById(R.id.user_right_status);
            holder.myLeftTXTTime = (TextView) view.findViewById(R.id.chat_left_TXT_time);

            view.setTag(holder);
        } else {
            view = convertView;
            holder = (ViewHolder) view.getTag();
        }
        String type = data.get(position).getType();
        String url = data.get(position).getURL();
        //Picasso.with(context).load(ServiceConstant.SOCKET_HOST_URL + url).into(holder.avatar);
        String message = data.get(position).getMessage();
        if (type.equalsIgnoreCase("SELF")) {
            if(data.get(position).getwarnings().equalsIgnoreCase("Yes")&& position==0){

                holder.warning.setVisibility(View.VISIBLE);
            }else{

                holder.warning.setVisibility(View.GONE);
            }
            holder.Rl_left.setVisibility(View.GONE);
            holder.Rl_right.setVisibility(View.VISIBLE);
            holder.Tv_rightMessage.setText(data.get(position).getMessage().trim());
            holder.mySeenStatusIMG.setVisibility(View.VISIBLE);
            if (!data.get(position).getSeenstatus().equals("")) {
                if (data.get(position).getSeenstatus().equals("1")) {
                    holder.mySeenStatusIMG.setImageResource(R.drawable.icon_double_tick_unseen);
                } else {
                    holder.mySeenStatusIMG.setImageResource(R.drawable.icon_double_tick_seen);
                }
            }
            if (!data.get(position).getDate().equals("")) {
                holder.myRightTXTTime.setVisibility(View.VISIBLE);
                String[] aSplitDateStr = data.get(position).getDate().split(",");
                int n=aSplitDateStr.length;
                holder.myRightTXTTime.setText(aSplitDateStr[n-1]);
            } else {
                holder.myRightTXTTime.setVisibility(View.GONE);
            }
            //holder.Tv_rightTime.setText(data.get(position).getTime());
        } else if (type.equalsIgnoreCase("OTHER")) {
            if(data.get(position).getwarnings().equalsIgnoreCase("Yes")&& position==0){

                holder.warning.setVisibility(View.VISIBLE);
            }else{

                holder.warning.setVisibility(View.GONE);
            }
            holder.Rl_left.setVisibility(View.VISIBLE);
            holder.Rl_right.setVisibility(View.GONE);
            // holder2.Tv_leftMessage.setText(Emoji.replaceEmoji(data.get(position).getMessage(), holder2.Tv_leftMessage.getPaint().getFontMetricsInt(), AndroidUtilities.dp(16)));
            holder.Tv_leftMessage.setText(data.get(position).getMessage().trim());
            //holder.Tv_leftTime.setText(data.get(position).getTime());
            if (!data.get(position).getDate().equals("")) {
                holder.myLeftTXTTime.setVisibility(View.VISIBLE);
                String[] aSplitDateStr = data.get(position).getDate().split(",");
                int n=aSplitDateStr.length;
                holder.myLeftTXTTime.setText(aSplitDateStr[n-1]);
            } else {
                holder.myLeftTXTTime.setVisibility(View.GONE);
            }
        } else if (type.equalsIgnoreCase("TYPING")) {
            holder.Rl_left.setVisibility(View.GONE);
            holder.Rl_right.setVisibility(View.GONE);
            holder.myLeftTXTTime.setVisibility(View.GONE);
            holder.myRightTXTTime.setVisibility(View.GONE);

    }

        holder.warning.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                AlertDialog.Builder builder = new AlertDialog.Builder(context, R.style.MyAlertDialogStyle);
                builder.setMessage(context.getResources().getString(R.string.warning1));
                builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
                    @Override
                    public void onClick(DialogInterface dialogInterface, int i) {

                    }
                });

                builder.show();
            }
        });


        return view;
    }
}
