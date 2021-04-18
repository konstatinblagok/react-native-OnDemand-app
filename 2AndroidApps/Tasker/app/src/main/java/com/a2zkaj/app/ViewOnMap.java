package com.a2zkaj.app;

import android.os.Bundle;
import android.widget.Toast;

import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.a2zkaj.Utils.ConnectionDetector;
import com.a2zkaj.Utils.SessionManager;
import com.a2zkaj.hockeyapp.ActionBarActivityHockeyApp;

import java.util.HashMap;

import core.socket.SocketHandler;

/**
 * Created by user88 on 12/16/2015.
 */
public class ViewOnMap extends ActionBarActivityHockeyApp {

    private SessionManager session;
    private ConnectionDetector cd;
    private Boolean isInternetPresent = false;

    private GoogleMap googleMap;
    private String provider_id = "";
    private SocketHandler socketHandler;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.viewon_map);
        initialize();
        initilizeMap();
    }

    private void initialize() {
        session = new SessionManager(ViewOnMap.this);
        cd = new ConnectionDetector(ViewOnMap.this);
        socketHandler = SocketHandler.getInstance(this);

        // get user data from session
        HashMap<String, String> user = session.getUserDetails();
        provider_id = user.get(SessionManager.KEY_PROVIDERID);

    }

    private void initilizeMap() {
        if (googleMap == null) {
            googleMap = ((MapFragment) ViewOnMap.this.getFragmentManager().findFragmentById(R.id.viewon_map)).getMap();
            // check if map is created successfully or not
            if (googleMap == null) {
                Toast.makeText(ViewOnMap.this, getResources().getString(R.string.ongoing_detail_map_doesnotcreate_label), Toast.LENGTH_SHORT).show();
            }
        }
        // Changing map type
        googleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
        // Showing / hiding your current location
        googleMap.setMyLocationEnabled(false);
        // Enable / Disable zooming controls
        googleMap.getUiSettings().setZoomControlsEnabled(false);
        // Enable / Disable my location button
        googleMap.getUiSettings().setMyLocationButtonEnabled(false);
        // Enable / Disable Compass icon
        googleMap.getUiSettings().setCompassEnabled(false);
        // Enable / Disable Rotate gesture
        googleMap.getUiSettings().setRotateGesturesEnabled(true);
        // Enable / Disable zooming functionality
        googleMap.getUiSettings().setZoomGesturesEnabled(true);
        googleMap.setMyLocationEnabled(false);

    }


}
