package com.a2zkaj.Pojo;

/**
 * Created by user88 on 12/15/2015.
 */
public class NewLeadsPojo {
    private String newleads_order_id;
    private String newleads_user_name;
    private String newleads_user_image;
    private String newleads_location;
    private String newleads_category;
    private String newleads_jobstatus;
    private String newleads_jobtime;
    private String latitude="";
    private String longitude="";
    private String Address="";
    public String getAddress() {
        return Address;
    }

    public void setAddress(String address) {
        Address = address;
    }



    public String getLongitude() {
        return longitude;
    }

    public void setLongitude(String longitude) {
        this.longitude = longitude;
    }

    public String getLatitude() {
        return latitude;
    }

    public void setLatitude(String latitude) {
        this.latitude = latitude;
    }

    public String getNewleads_jobtime() {
        return newleads_jobtime;
    }

    public void setNewleads_jobtime(String newleads_jobtime) {
        this.newleads_jobtime = newleads_jobtime;
    }

    public String getNewleads_jobstatus() {
        return newleads_jobstatus;
    }

    public void setNewleads_jobstatus(String newleads_jobstatus) {
        this.newleads_jobstatus = newleads_jobstatus;
    }

    public String getNewleads_jabtimeand_date() {
        return newleads_jabtimeand_date;
    }

    public void setNewleads_jabtimeand_date(String newleads_jabtimeand_date) {
        this.newleads_jabtimeand_date = newleads_jabtimeand_date;
    }

    private String newleads_jabtimeand_date;

    public String getNewleads_order_id() {
        return newleads_order_id;
    }

    public void setNewleads_order_id(String newleads_order_id) {
        this.newleads_order_id = newleads_order_id;
    }

    public String getNewleads_user_name() {
        return newleads_user_name;
    }

    public void setNewleads_user_name(String newleads_user_name) {
        this.newleads_user_name = newleads_user_name;
    }

    public String getNewleads_user_image() {
        return newleads_user_image;
    }

    public void setNewleads_user_image(String newleads_user_image) {
        this.newleads_user_image = newleads_user_image;
    }

    public String getNewleads_location() {
        return newleads_location;
    }

    public void setNewleads_location(String newleads_location) {
        this.newleads_location = newleads_location;
    }

    public String getNewleads_category() {
        return newleads_category;
    }

    public void setNewleads_category(String newleads_category) {
        this.newleads_category = newleads_category;
    }
}
