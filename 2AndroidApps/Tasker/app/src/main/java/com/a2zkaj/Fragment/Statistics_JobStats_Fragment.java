/*
package com.Fragment;

import android.content.Context;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;

import ConnectionDetector;
import SessionManager;
import com.android.volley.Request;
import com.casperon.plumabalpartner.R;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.listener.OnChartValueSelectedListener;
import com.github.mikephil.charting.utils.ColorTemplate;
import com.github.mikephil.charting.utils.Highlight;
import com.github.mikephil.charting.utils.PercentFormatter;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import mylibrary.Dialog.LoadingDialog;
import mylibrary.Dialog.PkDialog;
import mylibrary.Volley.ServiceRequest;
import mylibrary.service.ServiceConstant;

*/
/**
 * Created by user88 on 1/7/2016.
 *//*


public class Statistics_JobStats_Fragment extends Fragment {

    private RelativeLayout layout_main;

    private PieChart mchart;

    private Handler mHandler;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager mySession;
    private String provider_id = "";

    private ArrayList<String> jobstate_list_title;
    private ArrayList<String>jobstate_ratio;
    private  String Str_jobs_Count ="";
    private LoadingDialog dialog;

    private RelativeLayout Rl_jobstate_nointernet_layout;


    ArrayList<Entry> PercentageValues;

    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootview = inflater.inflate(R.layout.jobstate, container, false);

        init(rootview);

*/
/*mchart.setOnChartValueSelectedListener(new OnChartValueSelectedListener() {
            @Override
            public void onValueSelected(Entry e, int dataSetIndex, Highlight h) {

            }

            @Override
            public void onNothingSelected() {

            }
        });*//*



        return rootview;

    }

     private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        mySession = new SessionManager(getActivity());
        isInternetPresent=cd.isConnectingToInternet();
        PercentageValues = new ArrayList<Entry>();
        jobstate_list_title = new ArrayList<String>();
        jobstate_ratio = new ArrayList<String>();

        HashMap<String, String> user = mySession.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);
        layout_main = (RelativeLayout) rootview.findViewById(R.id.layout_pie_mainlayout);
         Rl_jobstate_nointernet_layout =(RelativeLayout)rootview.findViewById(R.id.layout_statistics_jobstates_noInternet);

        mchart = new PieChart(getActivity());
        layout_main.addView(mchart);
        layout_main.setBackgroundColor(Color.WHITE);


       // mchart.setUsePercentValues(true);
        mchart.setDescription("");
        mchart.setDrawHoleEnabled(true);
        mchart.setHoleColorTransparent(true);
        mchart.setHoleRadius(7);
        mchart.setTransparentCircleRadius(10);
        mchart.setRotationAngle(0);
        mchart.setRotationEnabled(true);


        if(isInternetPresent){

            layout_main.setVisibility(View.VISIBLE);
            Rl_jobstate_nointernet_layout.setVisibility(View.GONE);

            jobstatesPostRequest(getActivity(), ServiceConstant.STATISTICS_JOB_STATES_URL);
            Legend l = mchart.getLegend();
            l.setPosition(Legend.LegendPosition.LEFT_OF_CHART);
            l.setXEntrySpace(7);
            l.setYEntrySpace(5);
        }
        else
        {
            layout_main.setVisibility(View.GONE);
            Rl_jobstate_nointernet_layout.setVisibility(View.VISIBLE);
        }

    }

    //--------------Alert Method-----------
    private void Alert(String title, String message) {
        final PkDialog mDialog = new PkDialog(getActivity());
        mDialog.setDialogTitle(title);
        mDialog.setDialogMessage(message);
        mDialog.setPositiveButton(getResources().getString(R.string.server_ok_lable_header), new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mDialog.dismiss();
            }
        });
        mDialog.show();
    }

    private void jobstatesPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        System.out.println("provider_id-----------" + provider_id);

        dialog = new LoadingDialog(getActivity());
        dialog.setLoadingTitle(getResources().getString(R.string.loading_in));
        dialog.show();

        ServiceRequest mservicerequest = new ServiceRequest(mContext);
        mservicerequest.makeServiceRequest(url, Request.Method.POST, jsonParams, new ServiceRequest.ServiceListener() {

            @Override
            public void onCompleteListener(String response) {
                Log.e("jobstate", response);
                String Str_status = "", Str_response = "";

                try {

                    JSONObject jobject = new JSONObject(response);
                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        JSONArray jarry = object.getJSONArray("jobs");

                        if (jarry.length() > 0) {
                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject object1 = jarry.getJSONObject(i);
                                jobstate_list_title.add(object1.getString("title"));
                               // jobstate_list_title.add(" ");
                                jobstate_ratio.add(object1.getString("ratio"));

                                String Str_jobs_count = object1.getString("jobs_count");
                                PercentageValues.add(new Entry(Float.parseFloat(Str_jobs_count),i));
                            }
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (Str_status.equalsIgnoreCase("1")){
                    PieDataSet dataSet = new PieDataSet(PercentageValues,"Job status");
                    dataSet.setSliceSpace(2);
                    dataSet.setSelectionShift(2);

                    ArrayList<Integer>colors = new ArrayList<Integer>();
                    for (int c : ColorTemplate.VORDIPLOM_COLORS)
                        colors.add(c);

                    for (int c : ColorTemplate.JOYFUL_COLORS)
                        colors.add(c);

                    for (int c : ColorTemplate.COLORFUL_COLORS)
                        colors.add(c);

                    for (int c : ColorTemplate.LIBERTY_COLORS)
                        colors.add(c);

                    for (int c : ColorTemplate.PASTEL_COLORS)
                        colors.add(c);

                    colors.add(ColorTemplate.getHoloBlue());

                    dataSet.setColors(colors);

                    //---------adding all  values-----------------
                     PieData data = new PieData(jobstate_list_title,dataSet);
                     data.setValueFormatter(new PercentFormatter());
                     data.setValueTextSize(10f);
                     data.setValueTextColor(Color.BLACK);

                    mchart.setData(data);
                    mchart.highlightValues(null);
                    mchart.invalidate();
                }else{
                    Alert(getResources().getString(R.string.server_lable_header), Str_response);

                }
                dialog.dismiss();
            }

            @Override
            public void onErrorListener() {

                dialog.dismiss();

            }
        });


    }





}

*/
