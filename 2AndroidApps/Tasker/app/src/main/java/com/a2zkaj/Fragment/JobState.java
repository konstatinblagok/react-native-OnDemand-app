package com.a2zkaj.Fragment;

import android.content.Context;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.text.SpannableString;
import android.text.style.ForegroundColorSpan;
import android.text.style.RelativeSizeSpan;
import android.text.style.StyleSpan;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.RelativeLayout;

import com.android.volley.Request;
import com.github.mikephil.charting.charts.PieChart;
import com.github.mikephil.charting.components.Legend;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.PieData;
import com.github.mikephil.charting.data.PieDataSet;
import com.github.mikephil.charting.listener.OnChartValueSelectedListener;
import com.github.mikephil.charting.utils.ColorTemplate;
import com.github.mikephil.charting.utils.Highlight;
import com.github.mikephil.charting.utils.PercentFormatter;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.app.R;
import com.a2zkaj.hockeyapp.FragmentHockeyApp;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashMap;

import core.Dialog.LoadingDialog;
import core.Dialog.PkDialog;
import core.Volley.ServiceRequest;
import core.service.ServiceConstant;
import core.socket.SocketHandler;

/**
 * Created by user88 on 1/7/2016.
 */
public class JobState extends FragmentHockeyApp {

    private PieChart mChart;
    private Handler mHandler;
    private Boolean isInternetPresent = false;
    private ConnectionDetector cd;
    private SessionManager session;
    private String provider_id = "";

    private ArrayList<String> jobstate_list_title;
    private ArrayList<String> jobstate_ratio;
    private String Str_jobs_Count = "";
    private LoadingDialog dialog;
    private Typeface tf;

    private RelativeLayout Rl_jobstate_nointernet_layout;

    ArrayList<Entry> PercentageValues;
    private SocketHandler socketHandler;


    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View rootview = inflater.inflate(R.layout.activity_piechart, container, false);

        getActivity().getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        socketHandler = SocketHandler.getInstance(getActivity());
        init(rootview);
        return rootview;
    }


    private void init(View rootview) {
        cd = new ConnectionDetector(getActivity());
        session = new SessionManager(getActivity());
        isInternetPresent = cd.isConnectingToInternet();
        PercentageValues = new ArrayList<Entry>();
        jobstate_list_title = new ArrayList<String>();
        jobstate_ratio = new ArrayList<String>();

        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

        mChart = new PieChart(getActivity());

        mChart = (PieChart) rootview.findViewById(R.id.chart1);
        mChart.setUsePercentValues(true);
        mChart.setDescription("");
        // mChart.setDescription("Job States");
        //mChart.setExtraOffsets(5, 10, 5, 5);

        mChart.setCenterTextTypeface(Typeface.createFromAsset(getActivity().getAssets(), "fonts/Roboto-Medium.ttf"));
        tf = Typeface.createFromAsset(getActivity().getAssets(), "fonts/Roboto-Medium.ttf");
        // mChart.setCenterText("Job States");
        mChart.setCenterTextColor(getResources().getColor(R.color.colorAccent));
        mChart.setCenterTextSize(18f);

        mChart.setDrawHoleEnabled(true);
        mChart.setHoleColorTransparent(true);
        mChart.setHoleRadius(58f);
        mChart.setTransparentCircleRadius(61f);
        mChart.setDrawCenterText(true);

        mChart.setRotationAngle(0);
        // enable rotation of the chart by touch
        mChart.setRotationEnabled(false);
        mChart.setClickable(true);


        mChart.setOnChartValueSelectedListener(new OnChartValueSelectedListener() {
            @Override
            public void onValueSelected(Entry e, int dataSetIndex, Highlight h) {

            }

            @Override
            public void onNothingSelected() {

            }
        });


        isInternetPresent = cd.isConnectingToInternet();
        if (isInternetPresent) {

            jobstatesPostRequest(getActivity(), ServiceConstant.STATISTICS_JOB_STATES_URL);

            System.out.println("jobstate-------------" + ServiceConstant.STATISTICS_JOB_STATES_URL);

            Legend l = mChart.getLegend();
            l.setPosition(Legend.LegendPosition.RIGHT_OF_CHART);
            l.setXEntrySpace(7f);
            l.setYEntrySpace(0f);
            l.setYOffset(0f);
        } else {
            Alert(getResources().getString(R.string.alert_label_title), getResources().getString(R.string.alert_nointernet));
        }
    }

    private SpannableString generateCenterSpannableText() {

        SpannableString s = new SpannableString("Job Stats");
        s.setSpan(new RelativeSizeSpan(1.7f), 0, 14, 0);
        s.setSpan(new StyleSpan(Typeface.NORMAL), 14, s.length() - 15, 0);
        s.setSpan(new ForegroundColorSpan(Color.GRAY), 14, s.length() - 15, 0);
        s.setSpan(new RelativeSizeSpan(.8f), 14, s.length() - 15, 0);
        s.setSpan(new StyleSpan(Typeface.ITALIC), s.length() - 14, s.length(), 0);
        s.setSpan(new ForegroundColorSpan(ColorTemplate.getHoloBlue()), s.length() - 14, s.length(), 0);
        return s;
    }


    public boolean onCreateOptionsMenu(Menu menu) {
        getActivity().getMenuInflater().inflate(R.menu.pie, menu);
        return true;
    }


    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        switch (item.getItemId()) {
           /* case R.id.actionToggleValues: {
                for (IDataSet<?> set : mChart.getData().getDataSets())
                    set.setDrawValues(!set.isDrawValuesEnabled());

                mChart.invalidate();
                break;
            }*/
            case R.id.actionToggleHole: {
                if (mChart.isDrawHoleEnabled())
                    mChart.setDrawHoleEnabled(false);
                else
                    mChart.setDrawHoleEnabled(true);
                mChart.invalidate();
                break;
            }
            case R.id.actionDrawCenter: {
                if (mChart.isDrawCenterTextEnabled())
                    mChart.setDrawCenterText(false);
                else
                    mChart.setDrawCenterText(true);
                mChart.invalidate();
                break;
            }
            case R.id.actionToggleXVals: {

                mChart.setDrawSliceText(!mChart.isDrawSliceTextEnabled());
                mChart.invalidate();
                break;
            }
            case R.id.actionSave: {
                // mChart.saveToGallery("title"+System.currentTimeMillis());
                mChart.saveToPath("title" + System.currentTimeMillis(), "");
                break;
            }
            case R.id.actionTogglePercent:
                mChart.setUsePercentValues(!mChart.isUsePercentValuesEnabled());
                mChart.invalidate();
                break;
            case R.id.animateX: {
                mChart.animateX(1400);
                break;
            }
            case R.id.animateY: {
                mChart.animateY(1400);
                break;
            }
            case R.id.animateXY: {
                mChart.animateXY(1400, 1400);
                break;
            }
        }
        return true;
    }


    //---------------------------------code for job state post -----------------
    private void jobstatesPostRequest(Context mContext, String url) {
        HashMap<String, String> jsonParams = new HashMap<String, String>();
        jsonParams.put("provider_id", provider_id);
        System.out.println("provider_idjobstate-----------" + provider_id);

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

                    Log.e("jobstates", response);

                    Str_status = jobject.getString("status");

                    if (Str_status.equalsIgnoreCase("1")) {
                        JSONObject object = jobject.getJSONObject("response");
                        JSONArray jarry = object.getJSONArray("jobs");

                        if (jarry.length() > 0) {
                            for (int i = 0; i < jarry.length(); i++) {
                                JSONObject object1 = jarry.getJSONObject(i);

                                // jobstate_list_title.add(" ");
                                jobstate_ratio.add(object1.getString("ratio"));

                                String Str_jobs_count = object1.getString("jobs_count");

                                if (Str_jobs_count.equalsIgnoreCase("0")) {
                                    PercentageValues.remove(Str_jobs_count);
                                } else {

                                    PercentageValues.add(new Entry(Float.parseFloat(Str_jobs_count), i));
                                    jobstate_list_title.add(object1.getString("title"));
                                }


                            }
                        }
                    } else {
                        Str_response = jobject.getString("response");
                    }

                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (Str_status.equalsIgnoreCase("1")) {
                    PieDataSet dataSet = new PieDataSet(PercentageValues, getResources().getString(R.string.statistes_page_header_job_stats));
                    dataSet.setSliceSpace(2);
                    dataSet.setSelectionShift(2);

                    ArrayList<Integer> colors = new ArrayList<Integer>();
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
                    PieData data = new PieData(jobstate_list_title, dataSet);
                    data.setValueFormatter(new PercentFormatter());

                    data.setValueTextSize(9f);
                    data.setValueTextColor(Color.BLACK);
                    mChart.setData(data);

                    // undo all highlights
                    mChart.highlightValues(null);
                    mChart.invalidate();

                } else {
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


    @Override
    public void onResume() {
        super.onResume();
       /* if (!socketHandler.getSocketManager().isConnected){
            socketHandler.getSocketManager().connect();
        }*/

    }

}