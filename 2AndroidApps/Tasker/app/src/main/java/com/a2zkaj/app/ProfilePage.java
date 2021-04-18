package com.a2zkaj.app;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.support.design.widget.TabLayout;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.RelativeLayout;

import com.a2zkaj.Fragment.MyProfileFragment;
import com.a2zkaj.Fragment.MyProfileReviwesFragment;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import java.util.ArrayList;
import java.util.List;

import core.socket.SocketHandler;

/**
 * Created by user88 on 12/11/2015.
 */
public class ProfilePage extends ActionBarActivityHockeyApp {


    private TabLayout tabLayout;
    private ViewPager profile_viewPager;
    private RelativeLayout layout_profile_back;

    private SocketHandler socketHandler;

    public class RefreshReceiver extends BroadcastReceiver {
        @Override
        public void onReceive(Context context, Intent intent) {

            if(intent.getAction().equalsIgnoreCase("com.avail.finish")){
                finish();
            }

        }
    }

    private RefreshReceiver finishReceiver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.profile_page);
        socketHandler = SocketHandler.getInstance(this);
        profile_viewPager = (ViewPager) findViewById(R.id.profilepage_viewpager);
        layout_profile_back = (RelativeLayout) findViewById(R.id.layout_back_profilepage);
        setupViewPager(profile_viewPager);

        tabLayout = (TabLayout) findViewById(R.id.profilepage_tabs);
        tabLayout.setupWithViewPager(profile_viewPager);

        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.avail.finish");
        registerReceiver(finishReceiver, intentFilter);

        layout_profile_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

    }


    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(new MyProfileFragment(), getResources().getString(R.string.profilr_header_label));
        adapter.addFragment(new MyProfileReviwesFragment(), getResources().getString(R.string.profilr_header_label_reviews));
        viewPager.setAdapter(adapter);
    }


    class ViewPagerAdapter extends FragmentPagerAdapter {
        private final List<Fragment> mFragmentList = new ArrayList<>();
        private final List<String> mFragmentTitleList = new ArrayList<>();

        public ViewPagerAdapter(FragmentManager manager) {
            super(manager);
        }

        @Override
        public Fragment getItem(int position) {
            return mFragmentList.get(position);
        }

        @Override
        public int getCount() {
            return mFragmentList.size();
        }

        public void addFragment(Fragment fragment, String title) {
            mFragmentList.add(fragment);
            mFragmentTitleList.add(title);
        }

        @Override
        public CharSequence getPageTitle(int position) {
            return mFragmentTitleList.get(position);
        }
    }


    @Override
    public void onResume() {
        super.onResume();
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/
    }


}
