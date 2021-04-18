package com.a2zkaj.app;

import android.Manifest;
import android.content.Intent;
import android.content.IntentSender;
import android.content.pm.PackageManager;
import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Handler;
import android.os.SystemClock;
import android.support.annotation.NonNull;
import android.support.v4.app.ActivityCompat;
import android.support.v4.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.view.animation.Interpolator;
import android.view.animation.LinearInterpolator;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.PendingResult;
import com.google.android.gms.common.api.ResultCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.LocationSettingsRequest;
import com.google.android.gms.location.LocationSettingsResult;
import com.google.android.gms.location.LocationSettingsStatusCodes;
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
import com.a2zkaj.Utils.LatLngInterpolator;
import com.a2zkaj.Utils.MarkerAnimation;
import com.a2zkaj.hockeyapp.ActivityHockeyApp;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.w3c.dom.Document;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

import core.Map.CallBack;
import core.Map.GPSTracker;
import core.Map.GeocoderHelper;
import core.socket.SocketManager;
import cz.msebera.android.httpclient.Header;

public class Track_your_ride extends ActivityHockeyApp implements View.OnClickListener, GoogleApiClient.ConnectionCallbacks,
        GoogleApiClient.OnConnectionFailedListener, com.google.android.gms.location.LocationListener {
    GPSTracker gps;
    private GoogleMap googleMap;
    private int LOCATION_UPDATING_INTERVEL = 5000;
    private int LOCATION_UPDATING_FASTINTERVEL = 5000;
    private double dest_lat;
    private double dest_long;
    private ImageView back_ongoingback;
    private Marker curentDriverMarker;
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
    private String Current_Address = "";
    private ImageView track_ride;
    float bearingValue;
    LatLng pickup_latlong = null, drop_latlong = null, cur_latlong = null, return_latLong = null;
    //Moving Marker
    final int PERMISSION_REQUEST_CODE = 111;

    //Moving Marker
    private LatLng newLatLng, oldLatLng;
    private LatLngInterpolator mLatLngInterpolator;
    private Location oldLocation;
    private double myMovingDistance = 0.0;

    private LocationRequest mLocationRequest;
    private GoogleApiClient mGoogleApiClient;
    private PendingResult<LocationSettingsResult> result;
    private final static int REQUEST_LOCATION = 199;
    public static Location myLocation;
    private double MyCurrent_lat = 0.0, MyCurrent_long = 0.0;
    String destination_address="";
    private TextView user_address;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.trackdestination_layout);
        intilize();
        initilizeMap();

        try {
            setLocationRequest();
            buildGoogleApiClient();
            startLocationUpdates();
        } catch (Exception e) {
        }


        back_ongoingback.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                Intent i = new Intent();
                i.setAction("com.refresh.jobpage");
                sendBroadcast(i);

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
        time = (TextView) findViewById(R.id.time);
        kmeter = (TextView) findViewById(R.id.kilometer);
        tasker_location = (TextView) findViewById(R.id.tasker_location);
        track_ride = (ImageView) findViewById(R.id.track_ride);
        user_address=(TextView)findViewById(R.id.user_address);
        gps = new GPSTracker(Track_your_ride.this);


        Intent intent = getIntent();
        if (intent != null) {
            dest_lat = Double.parseDouble(intent.getStringExtra("LAT"));
            dest_long = Double.parseDouble(intent.getStringExtra("LONG"));
            Str_Userid = intent.getStringExtra("Userid");
            provider_id = intent.getStringExtra("tasker");
            mTaskID = intent.getStringExtra("task");
            destination_address=intent.getStringExtra("address");

        }
            user_address.setText(destination_address);


    }

    private void initilizeMap() {
        if (googleMap == null) {
            googleMap = ((MapFragment) getFragmentManager().findFragmentById(R.id.myjob_ongoing_detail_map)).getMap();
            if (googleMap == null) {
                Toast.makeText(Track_your_ride.this, getResources().getString(R.string.ongoing_detail_map_doesnotcreate_label), Toast.LENGTH_SHORT).show();
            }
            googleMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);
            googleMap.getUiSettings().setZoomControlsEnabled(false);
            googleMap.getUiSettings().setCompassEnabled(false);
            googleMap.getUiSettings().setRotateGesturesEnabled(true);
            // Enable / Disable zooming functionality
            googleMap.getUiSettings().setZoomGesturesEnabled(true);
            googleMap.setMyLocationEnabled(false);
        }

        if (gps != null && gps.canGetLocation()) {
            double Dlatitude = gps.getLatitude();
            double Dlongitude = gps.getLongitude();
            MyCurrent_lat = Dlatitude;
            MyCurrent_long = Dlongitude;

            CameraPosition cameraPosition = new CameraPosition.Builder().target(new LatLng(Dlatitude, Dlongitude)).zoom(15).build();
            googleMap.animateCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
            MarkerOptions marker = new MarkerOptions().position(new LatLng(Dlatitude, Dlongitude));
            driverLat = String.valueOf(dest_lat);
            driverLong = String.valueOf(dest_long);
        } else {
            enableGpsService();
        }

        if (driverLat != null && driverLong != null) {

            fromPosition = new LatLng(MyCurrent_lat, MyCurrent_long);
            toPosition = new LatLng(dest_lat, dest_long);

            if (fromPosition != null && toPosition != null) {

                GetDistance(fromPosition, toPosition);
                GetRouteTask draw_route_asyncTask = new GetRouteTask(fromPosition, toPosition);
                draw_route_asyncTask.execute();
            }

        }

//        Current_Address = getCompleteAddressString(MyCurrent_lat, MyCurrent_long);
//        tasker_location.setText(Current_Address);
       String address = new GeocoderHelper().fetchCityName(Track_your_ride.this, MyCurrent_lat, MyCurrent_long, callBacks);
    }

    CallBack callBacks = new CallBack() {
        @Override
        public void onComplete(String LocationName) {
            System.out.println("-------------------addreess----------------0" + LocationName);

            if (LocationName != null) {

                tasker_location.setText(LocationName);

            } else {
            }
        }

        @Override
        public void onError(String errorMsg) {

        }
    };

    private void CheckPermissions() {
        if (!checkAccessFineLocationPermission() || !checkAccessCoarseLocationPermission()) {
            requestPermission();
        } else {
            enableGpsService();
        }
    }


    @Override
    public void onStart() {
        super.onStart();
        if (mGoogleApiClient != null)
            mGoogleApiClient.connect();
    }

    @Override
    protected void onStop() {
        super.onStop();

        if (mGoogleApiClient != null)
            mGoogleApiClient.disconnect();
    }

    @Override
    protected void onResume() {
        super.onResume();

        if (myLocation == null) {
            myLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        }

    }

    private void setLocationRequest() {
        mLocationRequest = new LocationRequest();
        mLocationRequest.setInterval(10000);
        mLocationRequest.setFastestInterval(5000);
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
    }

    private void SetRouteMap(LatLng fromPosition, LatLng toPosition) {
        if (fromPosition != null && toPosition != null) {
            GetRouteTask getRoute = new GetRouteTask(fromPosition, toPosition);
            getRoute.execute();
        }
    }

    protected void startLocationUpdates() {
        if (mGoogleApiClient != null && mGoogleApiClient.isConnected()) {
            LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);
        }
    }


    protected synchronized void buildGoogleApiClient() {
        mGoogleApiClient = new GoogleApiClient.Builder(this)
                .addConnectionCallbacks(this)
                .addOnConnectionFailedListener(this)
                .addApi(LocationServices.API)
                .build();
    }


    //Enabling Gps Service
    private void enableGpsService() {
        mLocationRequest = LocationRequest.create();
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        mLocationRequest.setInterval(30 * 1000);
        mLocationRequest.setFastestInterval(5 * 1000);
        LocationSettingsRequest.Builder builder = new LocationSettingsRequest.Builder()
                .addLocationRequest(mLocationRequest);
        builder.setAlwaysShow(true);
        result = LocationServices.SettingsApi.checkLocationSettings(mGoogleApiClient, builder.build());
        result.setResultCallback(new ResultCallback<LocationSettingsResult>() {
            @Override
            public void onResult(LocationSettingsResult result) {
                final com.google.android.gms.common.api.Status status = result.getStatus();
                //final LocationSettingsStates state = result.getLocationSettingsStates();
                switch (status.getStatusCode()) {
                    case LocationSettingsStatusCodes.SUCCESS:
                        // All location settings are satisfied. The client can initialize location
                        // requests here.
                        //...
                        break;
                    case LocationSettingsStatusCodes.RESOLUTION_REQUIRED:
                        // Location settings are not satisfied. But could be fixed by showing the user
                        // a dialog.
                        try {
                            // Show the dialog by calling startResolutionForResult(),
                            // and check the result in onActivityResult().
                            status.startResolutionForResult(Track_your_ride.this, REQUEST_LOCATION);
                        } catch (IntentSender.SendIntentException e) {
                            // Ignore the error.
                        }
                        break;
                    case LocationSettingsStatusCodes.SETTINGS_CHANGE_UNAVAILABLE:
                        // Location settings are not satisfied. However, we have no way to fix the
                        // settings so we won't show the dialog.
                        //...
                        break;
                }
            }
        });
    }
    private boolean checkAccessFineLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }

    private boolean checkAccessCoarseLocationPermission() {
        int result = ContextCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_COARSE_LOCATION);
        if (result == PackageManager.PERMISSION_GRANTED) {
            return true;
        } else {
            return false;
        }
    }
    private void requestPermission() {
        ActivityCompat.requestPermissions(this, new String[]{android.Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION}, PERMISSION_REQUEST_CODE);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String permissions[], int[] grantResults) {
        switch (requestCode) {
            case PERMISSION_REQUEST_CODE:
                if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    enableGpsService();
                } else {

                }
                break;
        }
    }
    @Override
    public void onConnected(Bundle bundle) {
        myLocation = LocationServices.FusedLocationApi.getLastLocation(mGoogleApiClient);
        LocationServices.FusedLocationApi.requestLocationUpdates(mGoogleApiClient, mLocationRequest, this);
    }

    @Override
    public void onConnectionSuspended(int i) {
    }

    @Override
    public void onConnectionFailed(@NonNull ConnectionResult connectionResult) {
    }


    @Override
    public void onLocationChanged(Location location) {

        this.myLocation = location;
        if (myLocation != null) {

            try {
                LatLng latLng = new LatLng(myLocation.getLatitude(), myLocation.getLongitude());
                cur_latlong = new LatLng(myLocation.getLatitude(), myLocation.getLongitude());

                MyCurrent_lat = myLocation.getLatitude();
                MyCurrent_long = myLocation.getLongitude();
                if (oldLatLng == null) {
                    oldLatLng = latLng;
                }
                newLatLng = latLng;

                if (mLatLngInterpolator == null) {
                    mLatLngInterpolator = new LatLngInterpolator.Linear();
                }

                oldLocation = new Location("");
                oldLocation.setLatitude(oldLatLng.latitude);
                oldLocation.setLongitude(oldLatLng.longitude);
                float bearingValue = oldLocation.bearingTo(location);
                myMovingDistance = oldLocation.distanceTo(location);

                System.out.println("moving distance------------" + myMovingDistance);
                if (googleMap != null) {

                    if (myMovingDistance > 1) {
                        if (curentDriverMarker != null) {
                            if (!String.valueOf(bearingValue).equalsIgnoreCase("NaN")) {
                                // if (location.getAccuracy() < 100.0 && location.getSpeed() < 6.95) {
                                rotateMarker(curentDriverMarker, bearingValue, googleMap);
                                MarkerAnimation.animateMarkerToGB(curentDriverMarker, latLng, mLatLngInterpolator);
                                float zoom = googleMap.getCameraPosition().zoom;
                                CameraPosition cameraPosition = new CameraPosition.Builder().target(latLng).zoom(zoom).build();
                                googleMap.moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));

                                final LatLng latLngs = new LatLng(myLocation.getLatitude(), myLocation.getLongitude());
                                final LatLng toLatLng = new LatLng(dest_lat, dest_long);
                                GetDistance(latLngs, toLatLng);
                                sendLocationToTheUser(myLocation, bearingValue);
                                //  }
                            }
                        } else {
                            curentDriverMarker.remove();
                            curentDriverMarker = googleMap.addMarker(new MarkerOptions()
                                    .position(latLng)
                                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.carmoves))
                                    .anchor(0.5f, 0.5f)
                                    .rotation(myLocation.getBearing())
                                    .flat(true));
                        }
                    }
                }

                oldLatLng = newLatLng;
            } catch (Exception e) {
            }

        }
    }


    //Method to smooth turn marker
    static public void rotateMarker(final Marker marker, final float toRotation, GoogleMap map) {
        final Handler handler = new Handler();
        final long start = SystemClock.uptimeMillis();
        final float startRotation = marker.getRotation();
        final long duration = 1555;

        final Interpolator interpolator = new LinearInterpolator();

        handler.post(new Runnable() {
            @Override
            public void run() {
                long elapsed = SystemClock.uptimeMillis() - start;
                float t = interpolator.getInterpolation((float) elapsed / duration);

                float rot = t * toRotation + (1 - t) * startRotation;

                marker.setRotation(-rot > 180 ? rot / 2 : rot);
                if (t < 1.0) {
                    // Post again 16ms later.
                    handler.postDelayed(this, 16);
                }
            }
        });
    }


    JSONObject job = new JSONObject();

    private void sendLocationToTheUser(Location location, float bearing) throws JSONException {

        sendlat = Double.valueOf(location.getLatitude()).toString();
        sendlng = Double.valueOf(location.getLongitude()).toString();

        Double addresslatitude = Double.valueOf(sendlat);
        Double addresslongintude = Double.valueOf(sendlng);
        String selected_address = new GeocoderHelper().fetchCityName(Track_your_ride.this,addresslatitude, addresslongintude, callBack);
//        Current_Address = getCompleteAddressString(addresslatitude, addresslongintude);
//        tasker_location.setText(Current_Address);
        if (job == null) {
            job = new JSONObject();
        }
        job.put("user", Str_Userid);
        job.put("tasker", provider_id);
        job.put("task", mTaskID);
        job.put("bearing", String.valueOf(bearing));
        job.put("lat", sendlat);
        job.put("lng", sendlng);

        smanager.sendlocation(job);

    }



    CallBack callBack = new CallBack() {
        @Override
        public void onComplete(String LocationName) {
            System.out.println("-------------------addreess----------------0" + LocationName);

            if (LocationName != null) {

                tasker_location.setText(LocationName);

            } else {
            }
        }

        @Override
        public void onError(String errorMsg) {

        }
    };


    @Override
    public void onClick(View view) {
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
            m[1] = googleMap.addMarker(new MarkerOptions().position(toPosition).icon(BitmapDescriptorFactory.
                    fromResource(R.drawable.greenmark)));

            // Adding route on the map
            if (curentDriverMarker != null) {
                curentDriverMarker.remove();
            }

            curentDriverMarker = googleMap.addMarker(new MarkerOptions()
                    .position(fromPosition)
                    .icon(BitmapDescriptorFactory.fromResource(R.drawable.carmoves)));
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
                // googleMap.clear();
                try {
                    ArrayList<LatLng> directionPoint = v2GetRouteDirection.getDirection(document);
                    PolylineOptions rectLine = new PolylineOptions().width(18).color(
                            getResources().getColor(R.color.app_color));
                    for (int i = 0; i < directionPoint.size(); i++) {
                        rectLine.add(directionPoint.get(i));
                    }

                    Marker m[] = new Marker[2];
                    m[0] = googleMap.addMarker(new MarkerOptions().position(fromPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.redmark)));
                    m[1] = googleMap.addMarker(new MarkerOptions().position(toPosition).icon(BitmapDescriptorFactory.fromResource(R.drawable.greenmark)));


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


    public void GetDistance(LatLng start, LatLng end) {

        String url1 = "https://maps.googleapis.com/maps/api/distancematrix/json?key=AIzaSyCgwBM4YLj1gCHpRw2e29tN8QaXRJApU1Y&origins=" + start.latitude + "," + start.longitude + "&destinations=" + end.latitude + "," + end.longitude;
        System.out.println("---Url---------" + url1);
        String url = "http://maps.googleapis.com/maps/api/directions/xml?"
                + "origin=" + start.latitude + "," + start.longitude
                + "&destination=" + end.latitude + "," + end.longitude
                + "&sensor=false&units=metric&mode=driving";
        AsyncHttpClient distance = new AsyncHttpClient();
        distance.post(url1, null, new TextHttpResponseHandler() {
            @Override
            public void onFailure(int statusCode, Header[] headers, String responseString, Throwable throwable) {
                Toast.makeText(getApplicationContext(), "Failure", Toast.LENGTH_LONG).show();
            }

            @Override
            public void onSuccess(int statusCode, Header[] headers, String responseString) {

                System.out.println("------------------Response distance-------------" + responseString);
                //  Toast.makeText(getApplicationContext(),"Distance get",Toast.LENGTH_LONG).show();
                GetDuration(responseString);

            }
        });

    }


    public void GetDuration(String response) {
        System.out.print("-------------------Response-----------------" + response);
        String status = " ";
        // layaddress.setVisibility(View.VISIBLE);
        try {
            JSONObject ob = new JSONObject(response);
            JSONArray dest = ob.getJSONArray("destination_addresses");
            status = ob.getString("status");
            if (status.equalsIgnoreCase("OK")) {
                if (dest.length() > 0) {
                    JSONArray row = ob.getJSONArray("rows");

                    JSONObject object = (JSONObject) row.get(0);
                    JSONArray elementsArray = object.getJSONArray("elements");
                    JSONObject distance = (JSONObject) elementsArray.get(0);
                    JSONObject distanceObject = (JSONObject) distance.get("distance");


                    String kilometer = distanceObject.getString("text");
                    kmeter.setText("(" + kilometer + ")");

//                    String kilometer=distanceObject.getString("value");
//                    double km=Double.parseDouble(kilometer);
//                    double mi = km * 0.000621371;
//                    DecimalFormat df = new DecimalFormat("#.#");
//                    df.setRoundingMode(RoundingMode.HALF_UP);
//                    kmeter.setText("("+df.format(mi)+" mi"+")");

                    JSONObject distanceObject1 = (JSONObject) distance.get("duration");
                    // JSONObject duration=distance1.getJSONObject("duration");
                    String dur = distanceObject1.getString("text");
                    time.setText(dur);


                }

            }


        } catch (JSONException e) {
            e.printStackTrace();
        }
    }


    //-----------------------------------------------------------Current Address Get-----------------------------------------------------------------

    private String getCompleteAddressString(double LATITUDE, double LONGITUDE) {
        String strAdd = "";
        String loc_addr="";
        Geocoder geocoder = new Geocoder(getApplicationContext(), Locale.getDefault());
        try {
            List<Address> addresses = geocoder.getFromLocation(LATITUDE, LONGITUDE, 1);
            if (addresses != null) {
                Address returnedAddress = addresses.get(0);
                StringBuilder strReturnedAddress = new StringBuilder("");

                loc_addr=returnedAddress.getAddressLine(0);

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
        return loc_addr;
    }


}
