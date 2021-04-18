package com.a2zkaj.app;

import android.Manifest;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.MapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.LatLngBounds;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.PolylineOptions;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.TextHttpResponseHandler;
import com.a2zkaj.Utils.GMapV2GetRouteDirection;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import core.Map.GPSTracker;
import core.socket.SocketManager;
import cz.msebera.android.httpclient.Header;

/**
 */
public class TrackDestination extends ActivityHockeyApp implements View.OnClickListener, com.google.android.gms.location.LocationListener, GoogleApiClient.ConnectionCallbacks, GoogleApiClient.OnConnectionFailedListener {
    GPSTracker gps;
    private GoogleMap googleMap;
    private LocationRequest mLocationRequest;
    private GoogleApiClient mGoogleApiClient;
    private int LOCATION_UPDATING_INTERVEL = 5000;
    private int LOCATION_UPDATING_FASTINTERVEL = 5000;
    private double dest_lat;
    private double dest_long;
    private ImageView back_ongoingback;
    private static Marker curentDriverMarker;
    public static Location myLocation;
    private double MyCurrent_lat = 0.0, MyCurrent_long = 0.0;
    String sendlat = "";
    String sendlng = "";
    String Str_Userid = "";
    String provider_id = "";
    String mTaskID = "";
    static SocketManager smanager;
    String driverLat = "";
    String driverLong = "";
    private LatLng fromPosition;
    private LatLng toPosition;
    private TextView time;
    private TextView kmeter;
    private TextView tasker_location;
    private String Current_Address="";
    private ImageView track_ride;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trackdestination_layout);
        intilize();
        initilizeMap();
        back_ongoingback.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();

            }
        });

        if (smanager == null) {
            smanager = new SocketManager(this, new SocketManager.SocketCallBack() {

                @Override
                public void onSuccessListener(Object response) {
                    System.out.println("Location Updated Success--------------------->");
                }
            });
            if (!smanager.isConnected) {
                smanager.connect();
            }
        }

        track_ride.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String voice_curent_lat_long = MyCurrent_lat + "," + MyCurrent_long;
                String voice_destination_lat_long = dest_lat + "," + dest_long;
                System.out.println("----------fromPosition---------------" + voice_curent_lat_long);
                System.out.println("----------toPosition---------------" + voice_destination_lat_long);
                String locationUrl = "http://maps.google.com/maps?saddr=" + voice_curent_lat_long + "&daddr=" + voice_destination_lat_long;
                System.out.println("----------locationUrl---------------" + locationUrl);
                Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(locationUrl));
                startActivity(intent);
            }
        });


    }

    private void intilize() {
        back_ongoingback = (ImageView) findViewById(R.id.back_ongoingback);
        time=(TextView)findViewById(R.id.time);
        kmeter=(TextView)findViewById(R.id.kilometer);
        tasker_location=(TextView)findViewById(R.id.tasker_location);
        track_ride=(ImageView)findViewById(R.id.track_ride);


        gps = new GPSTracker(TrackDestination.this);
        Intent intent = getIntent();
        if (intent != null) {
            dest_lat = Double.parseDouble(intent.getStringExtra("LAT"));
            dest_long = Double.parseDouble(intent.getStringExtra("LONG"));
            Str_Userid = intent.getStringExtra("Userid");
            provider_id = intent.getStringExtra("tasker");
            mTaskID = intent.getStringExtra("task");

        }


    }

    private void initilizeMap() {
        if (googleMap == null) {
            googleMap = ((MapFragment) getFragmentManager().findFragmentById(R.id.myjob_ongoing_detail_map)).getMap();
            if (googleMap == null) {
                Toast.makeText(TrackDestination.this, getResources().getString(R.string.ongoing_detail_map_doesnotcreate_label), Toast.LENGTH_SHORT).show();
            }
            googleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
            googleMap.getUiSettings().setZoomControlsEnabled(false);
            googleMap.getUiSettings().setCompassEnabled(false);
            googleMap.getUiSettings().setRotateGesturesEnabled(true);
            // Enable / Disable zooming functionality
            googleMap.getUiSettings().setZoomGesturesEnabled(true);
            googleMap.setMyLocationEnabled(false);
        }


        if (gps.canGetLocation()) {
            double Dlatitude = gps.getLatitude();
            double Dlongitude = gps.getLongitude();
            MyCurrent_lat = Dlatitude;
            MyCurrent_long = Dlongitude;

            CameraPosition cameraPosition = new CameraPosition.Builder().target(new LatLng(Dlatitude, Dlongitude)).zoom(15).build();
            googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));

            MarkerOptions marker = new MarkerOptions().position(new LatLng(Dlatitude, Dlongitude));
            // marker.icon(BitmapDescriptorFactory.fromResource(R.drawable.maps));
            //  currentMarker = googleMap.addMarker(marker);
            System.out.println("currntlat----------" + MyCurrent_lat);
            System.out.println("currntlon----------" + MyCurrent_long);
            driverLat = String.valueOf(dest_lat);
            driverLong = String.valueOf(dest_long);

        }
        if (driverLat != null && driverLong != null) {


            fromPosition = new LatLng(MyCurrent_lat, MyCurrent_long);
            toPosition = new LatLng(dest_lat, dest_long);

              if (fromPosition != null && toPosition != null) {

                  GetDistance(fromPosition,toPosition);
                GetRouteTask draw_route_asyncTask = new GetRouteTask(fromPosition, toPosition);
                draw_route_asyncTask.execute();
            }

        }

        Current_Address= getCompleteAddressString(MyCurrent_lat,MyCurrent_long);
        tasker_location.setText(Current_Address);

        setLocationRequest();
        startLocationUpdates();
        buildGoogleApiClient();
    }

    private void setLocationRequest() {
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(LOCATION_UPDATING_INTERVEL);
        mLocationRequest.setFastestInterval(LOCATION_UPDATING_FASTINTERVEL);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
    }

    protected void startLocationUpdates() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected()) {
            LocationServices.FusedLocationApi.requestLocationUpdates(
                    mGoogleApiClient, mLocationRequest, this);
        }
    }

    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
        mGoogleApiClient.connect();
    }

    @Override
    public void onStart() {
        super.onStart();
        if (mGoogleApiClient != null)
            mGoogleApiClient.connect();
    }

    protected void onStop() {
        if (mGoogleApiClient != null) {
            mGoogleApiClient.disconnect();
        }
        super.onStop();
        //  mHandler.removeCallbacks(mHandlerTask);
    }

    @Override
    public void onConnected(Bundle bundle) {

        if (gps != null && gps.canGetLocation() && gps.isgpsenabled()) {
        }

        int result = ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            myLocation = LocationServices.FusedLocationApi.getLastLocation(
                    mGoogleApiClient);

            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);

        }

        if (myLocation != null) {
            googleMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(myLocation.getLatitude(), myLocation.getLongitude()),
                    16));
        }


        Location location = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        if (location != null) {


            LatLng fromLatLng = new LatLng(location.getLatitude(), location.getLongitude());

        }


    }

    @Override
    public void onConnectionSuspended(int i) {
    }

    MarkerOptions mm = new MarkerOptions();
    Marker drivermarker;
    JSONObject job = new JSONObject();

    @Override
    public void onLocationChanged(Location location) {
        this.myLocation = location;
        System.out.println("locatbegintrip-----------" + location);

        if (location != null) {

            try {
                final LatLng latLng = new LatLng(myLocation.getLatitude(), myLocation.getLongitude());
                final LatLng toLatLng = new LatLng(dest_lat, dest_long);
                GetDropRouteTask draw_route_asyncTask = new GetDropRouteTask();
                draw_route_asyncTask.setToAndFromLocation(latLng, toLatLng);
                draw_route_asyncTask.execute();
                // drawRouteInMap();



                Handler handler=new Handler();
                handler.postDelayed(new Runnable() {
                    @Override
                    public void run() {
                        try {

                            GetDistance(latLng,toLatLng);
                            sendLocationToTheUser(myLocation);
                        } catch (JSONException e) {
                            e.printStackTrace();
                        }


                    }
                }, 10000);



                if (drivermarker != null) {
                    drivermarker.remove();
                }
                // drivermarker = googleMap.addMarker(new MarkerOptions().position(latLng).icon(BitmapDescriptorFactory.fromResource(R.drawable.carmove)));
            } catch (Exception e) {
            }


        }
    }


    private void sendLocationToTheUser(Location location) throws JSONException {

        // manager = new ChatSocketManager((ChatSocketManager.SocketCallBack) MyJobs_OnGoingDetailPage.this);
        sendlat = Double.valueOf(location.getLatitude()).toString();
        sendlng = Double.valueOf(location.getLongitude()).toString();
          Toast.makeText(getApplicationContext(),sendlat+" "+sendlng,Toast.LENGTH_LONG).show();
        Double addresslatitude= Double.valueOf(sendlat);
        Double addresslongintude= Double.valueOf(sendlng);
        Current_Address=getCompleteAddressString(addresslatitude,addresslongintude);
        tasker_location.setText(Current_Address);
        if (job == null) {
            job = new JSONObject();
        }


        // job.put("from",Str_Userid);

        job.put("user", Str_Userid);
        job.put("tasker", provider_id);
        job.put("task", mTaskID);
        //  job.put("message","location");
        job.put("lat", sendlat);
        job.put("lng", sendlng);

        smanager.sendlocation(job);

    }

    @Override
    public void onClick(View view) {
    }

    @Override
    public void onConnectionFailed(ConnectionResult connectionResult) {
    }


    private class GetRouteTask extends AsyncTask<String, Void, String> {
        LatLngBounds bounds;
        String response = "";
        private LatLng fromPosition;
        private LatLng toPosition;
        Document document;
        private GMapV2GetRouteDirection v2GetRouteDirection;

        private GetRouteTask(LatLng fromPosition,
                             LatLng toPosition) {
            this.fromPosition = fromPosition;
            this.toPosition = toPosition;
            v2GetRouteDirection = new GMapV2GetRouteDirection();
        }

        @Override
        protected void onPreExecute() {
        }

        @Override
        protected String doInBackground(String... urls) {
            //Get All Route values
            document = v2GetRouteDirection.getDocument(fromPosition, toPosition, GMapV2GetRouteDirection.MODE_DRIVING);
            response = "Success";
            return response;

        }

        @Override
        protected void onPostExecute(String result) {
            googleMap.clear();

            ArrayList<LatLng> directionPoint = v2GetRouteDirection.getDirection(document);
            PolylineOptions rectLine = new PolylineOptions().width(18).color(getResources().getColor(R.color.app_color));
            for (int i = 0; i < directionPoint.size(); i++) {
                rectLine.add(directionPoint.get(i));
            }
            googleMap.addPolyline(rectLine);
            Marker m[] = new Marker[2];
            m[0] = googleMap.addMarker(new MarkerOptions().position(fromPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.redmark)));
            m[1] = googleMap.addMarker(new MarkerOptions().position(toPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.greenmark)));

            // Adding route on the map

            curentDriverMarker = googleMap.addMarker(new MarkerOptions()
                    .position(fromPosition)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.move_icon)));
            /*googleMap.addMarker(new MarkerOptions()
                    .position(toPosition)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.aboutus_icon)));*/
            LatLngBounds.Builder builder = new LatLngBounds.Builder();
            builder.include(toPosition);
            builder.include(fromPosition);
            bounds = builder.build();
            googleMap.setOnMapLoadedCallback(new GoogleMap.OnMapLoadedCallback() {
                @Override
                public void onMapLoaded() {
                    googleMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 40));
                }
            });

        }
    }


    //---------------AsyncTask to Draw PolyLine Between Two Point--------------
    private class GetDropRouteTask extends AsyncTask<String, Void, String> {

        String response = "";
        GMapV2GetRouteDirection v2GetRouteDirection = new GMapV2GetRouteDirection();
        Document document;
        private LatLng currentLocation;
        private LatLng endLocation;

        public void setToAndFromLocation(LatLng currentLocation, LatLng endLocation) {
            this.currentLocation = currentLocation;
            this.endLocation = endLocation;
        }

        @Override
        protected void onPreExecute() {
        }

        @Override
        protected String doInBackground(String... urls) {
            //Get All Route values
            document = v2GetRouteDirection.getDocument(endLocation, currentLocation, GMapV2GetRouteDirection.MODE_DRIVING);
            response = "Success";
            return response;

        }

        @Override
        protected void onPostExecute(String result) {
            if (result.equalsIgnoreCase("Success")) {
                googleMap.clear();
                try {
                    ArrayList<LatLng> directionPoint = v2GetRouteDirection.getDirection(document);
                    PolylineOptions rectLine = new PolylineOptions().width(18).color(
                            getResources().getColor(R.color.app_color));
                    for (int i = 0; i < directionPoint.size(); i++) {
                        rectLine.add(directionPoint.get(i));
                    }
                    // Adding route on the map
                    googleMap.addPolyline(rectLine);
//                    markerOptions.position(endLocation);
//                    markerOptions.position(currentLocation);
//                    markerOptions.draggable(true);

                    // googleMap.addMarker(markerOptions);
                    Marker m[] = new Marker[2];
                    m[0] = googleMap.addMarker(new MarkerOptions().position(fromPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.redmark)));
                    m[1] = googleMap.addMarker(new MarkerOptions().position(toPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.greenmark)));

                    curentDriverMarker = googleMap.addMarker(new MarkerOptions()
                            .position(currentLocation)
                            .icon(BitmapDescriptorFactory.fromResource(R.drawable.move_icon)));

                    System.out.println("inside---------marker--------------");

                    //Show path in
                    LatLngBounds.Builder builder = new LatLngBounds.Builder();
                    builder.include(endLocation);
                    builder.include(currentLocation);
                    LatLngBounds bounds = builder.build();
                    // googleMap.animateCamera(CameraUpdateFactory.newLatLngBounds(bounds, 162));
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public void GetDistance(LatLng start, LatLng end){

        String url1="https://maps.googleapis.com/maps/api/distancematrix/json?key=AIzaSyC-NdrqPUwtjWD8Y0d6Y-rpvZyE6TOJawU&origins="+ start.latitude + "," + start.longitude+"&destinations="+end.latitude + "," + end.longitude;
        System.out.println("---Url---------"+url1);
        String url = "http://maps.googleapis.com/maps/api/directions/xml?"
                + "origin=" + start.latitude + "," + start.longitude
                + "&destination=" + end.latitude + "," + end.longitude
                + "&sensor=false&units=metric&mode=driving";
        AsyncHttpClient distance=new AsyncHttpClient();
        distance.post(url1, null, new TextHttpResponseHandler() {
            @Override
            public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
                Toast.makeText(getApplicationContext(),"Failure",Toast.LENGTH_LONG).show();
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {

                System.out.println("------------------Response distance-------------"+responseString);
                //  Toast.makeText(getApplicationContext(),"Success",Toast.LENGTH_LONG).show();
                GetDuration(responseString);

            }
        });

    }



    public  void  GetDuration(String response){
        System.out.print("-------------------Response-----------------"+response);
        String status=" ";
        // layaddress.setVisibility(View.VISIBLE);
        try {
            JSONObject ob=new JSONObject(response);
            JSONArray dest=ob.getJSONArray("destination_addresses");
            status=ob.getString("status");
            if(status.equalsIgnoreCase("OK")){
                if(dest.length()>0){
                    JSONArray row=ob.getJSONArray("rows");

                    JSONObject object = (JSONObject) row.get(0);
                    JSONArray elementsArray =   object.getJSONArray("elements");
                    JSONObject distance = (JSONObject) elementsArray.get(0);
                    JSONObject distanceObject  = (JSONObject) distance.get("distance");


                    String kilometer=distanceObject.getString("text");
                    kmeter.setText("("+kilometer+")");

                    JSONObject distanceObject1  = (JSONObject) distance.get("duration");
                    // JSONObject duration=distance1.getJSONObject("duration");
                    String dur=distanceObject1.getString("text");
                    time.setText(dur);


                }

            }


        }
        catch (JSONException e) {
            e.printStackTrace();
        }
    }


    //-----------------------------------------------------------Current Address Get-----------------------------------------------------------------

    private String getCompleteAddressString(double LATITUDE, double LONGITUDE) {
        String strAdd = "";
        Geocoder geocoder = new Geocoder(getApplicationContext(), Locale.getDefault());
        try {
            List<Address> addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addresses != null) {
                Address returnedAddress = addresses.get(0);
                StringBuilder strReturnedAddress = new StringBuilder("");

                for (int i = 0; i <= returnedAddress.getMaxAddressLineIndex(); i++) {
                    strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n");
                }
                strAdd = strReturnedAddress.toString();
            } else {
                Log.e("Current loction address", "No Address returned!");
            }
        } catch (Exception e) {
            e.printStackTrace();
            Log.e("Current loction address", "Canont get Address!");
        }
        return strAdd;
    }



}
