package com.a2zkaj.adapter;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.R;
import com.squareup.picasso.Picasso;

import java.util.HashMap;

import core.Widgets.CircularImageView;


/**
 * Created by user88 on 12/9/2015.
 */
public class NavigationMenuAdapter extends BaseAdapter {
    Context context;
    String[] mTitle;
    int[] mIcon;
    LayoutInflater inflater;
    View itemView;
    public SessionManager session;

    private TextView username, user_email;

    private String profile_username = "", profile_user_email;


    private String provider_name, provide_img;

    public NavigationMenuAdapter(Context context, String[] title, int[] icon) {
        this.context = context;
        this.mTitle = title;
        this.mIcon = icon;
    }

    @Override
    public int getCount() {
        return mTitle.length;
    }

    @Override
    public Object getItem(int position) {
        return mTitle[position];
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        // Declare Variables
        TextView txtTitle, profile_name, profile_mobile;
        CircularImageView profile_icon;
        ImageView imgIcon;
        RelativeLayout profile_layout, listitem_layout;

        View drawer_view;

        session = new SessionManager(context);

        inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        itemView = inflater.inflate(R.layout.drawer_list_item, parent, false);

        txtTitle = (TextView) itemView.findViewById(R.id.title);
        imgIcon = (ImageView) itemView.findViewById(R.id.icon);
        profile_icon = (CircularImageView) itemView.findViewById(R.id.profile_icon);
        drawer_view = (View) itemView.findViewById(R.id.drawer_list_view);
        profile_layout = (RelativeLayout) itemView.findViewById(R.id.drawer_list_item_profile_layout);
        listitem_layout = (RelativeLayout) itemView.findViewById(R.id.drawer_list_item_layout);
        username = (TextView) itemView.findViewById(R.id.profile_user_name);
        user_email = (TextView) itemView.findViewById(R.id.profile_email_title);

        if (session.isLoggedIn()) {

            if (position == 0) {
                HashMap<String, String> user = session.getUserDetails();
                provider_name = user.get(SessionManager.KEY_PROVIDERNAME);
                provide_img = user.get(SessionManager.KEY_USERIMAGE);
                profile_user_email = user.get(SessionManager.KEY_EMAIL);

                profile_layout.setVisibility(View.VISIBLE);
                listitem_layout.setVisibility(View.GONE);
                drawer_view.setVisibility(View.GONE);

                System.out.println("name------------" + provider_name);

                username.setText(provider_name);
                user_email.setText(profile_user_email);
                Picasso.with(context).load(String.valueOf(provide_img)).placeholder(R.drawable.nouserimg).into(profile_icon);

            } else {

                if(position==1){
                    drawer_view.setVisibility(View.VISIBLE);
                }
                if(position==3){
                    drawer_view.setVisibility(View.VISIBLE);
                }
                if(position==5){
                    drawer_view.setVisibility(View.VISIBLE);
                }

                if(position==2){
                    drawer_view.setVisibility(View.VISIBLE);
                }

                if(position==4){
                    drawer_view.setVisibility(View.VISIBLE);
                }

                if(position==6){
                    drawer_view.setVisibility(View.VISIBLE);
                }

                if(position==7){
                    drawer_view.setVisibility(View.VISIBLE);
                }

                profile_layout.setVisibility(View.GONE);
                listitem_layout.setVisibility(View.VISIBLE);

                imgIcon.setImageResource(mIcon[position]);
                txtTitle.setText(mTitle[position]);
            /*    profile_layout.setVisibility(View.GONE);
                listitem_layout.setVisibility(View.VISIBLE);

                imgIcon.setImageResource(mIcon[position]);
                txtTitle.setText(mTitle[position]);*/
            }

        } else {
            if (position == 0) {
                profile_layout.setVisibility(View.VISIBLE);
                listitem_layout.setVisibility(View.GONE);
                drawer_view.setVisibility(View.GONE);

                username.setText(context.getResources().getString(R.string.mainpage_login_signin_lable));
                user_email.setVisibility(View.GONE);
            } else {
                if (position == 2) {
                    drawer_view.setVisibility(View.VISIBLE);
                } else {
                    drawer_view.setVisibility(View.GONE);
                }
                profile_layout.setVisibility(View.GONE);
                listitem_layout.setVisibility(View.VISIBLE);

                imgIcon.setImageResource(mIcon[position]);
                txtTitle.setText(mTitle[position]);
            }


        }


        return itemView;
    }
}

