package com.a2zkajuser.core.gps;

import android.content.Context;
import android.location.Address;
import android.location.Geocoder;
import android.net.http.AndroidHttpClient;
import android.os.AsyncTask;
import android.util.Log;

import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.BasicResponseHandler;
import org.json.JSONArray;
import org.json.JSONObject;

import java.util.List;
import java.util.Locale;

/**
 * Created by user145 on 10/10/2017.
 */
public class LocationGeo {

    private static final AndroidHttpClient ANDROID_HTTP_CLIENT = AndroidHttpClient.newInstance(GeocoderHelper.class.getName());

    private boolean running = false;
    private String City_name = "";
    LocationCallBackMethod callBack;
    String address1="";
    String city="";
    String state="";
    String country="";
    String postalCode="";
    String latitude="";
    String longintude="";

    public String fetchCityName(final Context contex, final double lat, final double log, LocationCallBackMethod callback) {
        callBack = callback;
        latitude= String.valueOf(lat);
        longintude= String.valueOf(log);
        if (running)
            return null;

        new AsyncTask<Void, Void, String>() {

            @Override
            protected void onPreExecute() {
                running = true;
            }

            ;

            @Override
            protected String doInBackground(Void... params) {
                String cityName = null;

                if (Geocoder.isPresent()) {
                    try {
                        Geocoder geocoder = new Geocoder(contex, Locale.getDefault());
                        List<Address> addresses = geocoder.getFromLocation(lat, log, 1);
                        System.out.println("========List================addresses" + addresses);

                        if (addresses.size() > 0) {
                            Address returnedAddress = addresses.get(0);
                            address1 = addresses.get(0).getAddressLine(0); // If any additional address line present than only, check with max available address lines by getMaxAddressLineIndex()
                            city = addresses.get(0).getLocality();
                            state = addresses.get(0).getAdminArea();
                            country = addresses.get(0).getCountryName();
                            postalCode = addresses.get(0).getPostalCode();
                            StringBuilder strReturnedAddress = new StringBuilder("");
                            System.out.println("------------getMaxAddressLineIndex--------------------" + returnedAddress.getMaxAddressLineIndex());
                            if (returnedAddress.getMaxAddressLineIndex() > 0) {

                                for (int i = 0; i < returnedAddress.getMaxAddressLineIndex(); i++) {
                                    strReturnedAddress.append(returnedAddress.getAddressLine(i)).append("\n");
                                }
                                cityName = strReturnedAddress.toString();
                            } else {
                                cityName = returnedAddress.getAddressLine(0);
                            }


                        }
                    } catch (Exception ignored) {
                        // after a while, Geocoder start to trhow "Service not availalbe" exception. really weird since it was working before (same device, same Android version etc..
                    }
                }

                if (cityName != null) // i.e., Geocoder succeed
                {
                    System.out.println("-------------------cityName----------------------" + cityName);
                    return cityName;
                } else // i.e., Geocoder failed
                {
                    System.out.println("--------fetchCityNameUsingGoogleMap-----------cityName----------------------" + cityName);
                    return fetchCityNameUsingGoogleMap();
                }
            }

            private String fetchCityNameUsingGoogleMap() {
                String googleMapUrl = "http://maps.googleapis.com/maps/api/geocode/json?latlng=" + lat + ","
                        + log + "&sensor=false";
                System.out.println("-----------------get address -url----------------------------" + googleMapUrl);
                try {
                    JSONObject googleMapResponse = new JSONObject(ANDROID_HTTP_CLIENT.execute(new HttpGet(googleMapUrl),
                            new BasicResponseHandler()));

                    // many nested loops.. not great -> use expression instead
                    // loop among all results
                    JSONArray results = (JSONArray) googleMapResponse.get("results");
                    for (int i = 0; i < results.length(); i++) {
                        // loop among all addresses within this result
                        JSONObject result = results.getJSONObject(i);
                        if (result.has("address_components")) {
                            JSONArray addressComponents = result.getJSONArray("address_components");
                            // loop among all address component to find a 'locality' or 'sublocality'
                            for (int j = 0; j < addressComponents.length(); j++) {
                                JSONObject addressComponent = addressComponents.getJSONObject(j);
                                if (result.has("types")) {
                                    JSONArray types = addressComponent.getJSONArray("types");

                                    // search for locality and sublocality
                                    String cityName = null;

                                    for (int k = 0; k < types.length(); k++) {
                                        if ("locality".equals(types.getString(k)) && cityName == null) {
                                            if (addressComponent.has("long_name")) {
                                                cityName = addressComponent.getString("long_name");
                                            } else if (addressComponent.has("short_name")) {
                                                cityName = addressComponent.getString("short_name");
                                            }
                                        }
                                        if ("sublocality".equals(types.getString(k))) {
                                            if (addressComponent.has("long_name")) {
                                                cityName = addressComponent.getString("long_name");
                                            } else if (addressComponent.has("short_name")) {
                                                cityName = addressComponent.getString("short_name");
                                            }
                                        }
                                    }
                                    if (cityName != null) {
                                        return cityName;
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception ignored) {
                    ignored.printStackTrace();
                }
                return null;
            }


            @Override
            protected void onPostExecute(String cityName) {
                City_name = cityName;
                callBack.onComplete(cityName,city,state,country,postalCode,latitude,longintude);
                running = false;
                if (cityName != null) {
                    // Do something with cityName
                    Log.i("GeocoderHelper", cityName);
                }

            }

            ;
        }.execute();
        return City_name;
    }
}
