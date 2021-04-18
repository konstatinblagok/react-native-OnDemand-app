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

import com.a2zkaj.Fragment.JobState;
import com.a2zkaj.Fragment.Statistics_EarningsStats_Fragment;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import java.util.ArrayList;
import java.util.List;

import core.socket.SocketHandler;

/**
 * Created by user88 on 12/31/2015.
 */
public class StatisticsPage extends ActionBarActivityHockeyApp {

    SessionManager session;
    ConnectionDetector cd;
    private Boolean isInternetPresent = false;


    private TabLayout tabLayout;
    private ViewPager viewPager;
    private RelativeLayout layout_statistics_back;
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
        setContentView(R.layout.staticspage);
        initialize();
    }

    private void initialize() {
        session = new SessionManager(StatisticsPage.this);
        cd = new ConnectionDetector(StatisticsPage.this);
        socketHandler = SocketHandler.getInstance(this);

        viewPager = (ViewPager) findViewById(R.id.statistics_viewpager);
        layout_statistics_back = (RelativeLayout) findViewById(R.id.layout_back_statistics);
        setupViewPager(viewPager);

        tabLayout = (TabLayout) findViewById(R.id.statistics_tabs);
        tabLayout.setupWithViewPager(viewPager);

        layout_statistics_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onBackPressed();
                overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
            }
        });

        finishReceiver = new RefreshReceiver();
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("com.avail.finish");
        registerReceiver(finishReceiver, intentFilter);
    }


    private void setupViewPager(ViewPager viewPager) {
        ViewPagerAdapter adapter = new ViewPagerAdapter(getSupportFragmentManager());
        adapter.addFragment(new Statistics_EarningsStats_Fragment(), getResources().getString(R.string.statistes_page_header_earnings_stats));
        adapter.addFragment(new JobState(), getResources().getString(R.string.statistes_page_header_job_stats));
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
        }
*/
    }


}


