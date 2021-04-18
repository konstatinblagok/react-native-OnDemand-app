package com.a2zkaj.Fragment;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

/**
 * Created by user88 on 12/10/2015.
 */
public class MyJobs extends FragmentHockeyApp {


    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        return inflater.inflate(R.layout.myjobs, container, false);
    }

}
