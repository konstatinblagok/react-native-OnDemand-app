package com.a2zkajuser.app;

import android.content.Intent;
import android.os.Bundle;
import android.widget.ImageView;

import com.a2zkajuser.R;
import com.a2zkajuser.hockeyapp.ActivityHockeyApp;
import com.squareup.picasso.MemoryPolicy;
import com.squareup.picasso.Picasso;

public class Profilpictureview extends ActivityHockeyApp {
ImageView image;
    String userimage="";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profilpictureview);
        image=(ImageView)findViewById(R.id.image);
        Intent i=getIntent();
        userimage=i.getExtras().getString("image");
        Picasso.with(getApplicationContext()).load(userimage).error(R.drawable.placeholder_icon)
                .placeholder(R.drawable.placeholder_icon).memoryPolicy(MemoryPolicy.NO_CACHE).into(image);




    }
}
