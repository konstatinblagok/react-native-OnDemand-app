package com.a2zkaj.Pojo;

/**
 * Created by user145 on 5/29/2017.
 */
public class UpdateCategorydatapojo {
    String Quickpinch = "";
    String hourlyRate = "";
    String levelOfexp = "";
    String Parentcategory = "";
    String ParentID = "";
    String ChildCategory = "";
    String ChildID = "";
    String minRate = "";
    Boolean isCategoryDataSaved = false;

    public String getQuickpinch() {
        return Quickpinch;
    }

    public void setQuickpinch(String quickpinch) {
        Quickpinch = quickpinch;
    }


    public String getChildCategory() {
        return ChildCategory;
    }

    public void setChildCategory(String childcategory) {
        ChildCategory = childcategory;
    }


    public String getParentID() {
        return ParentID;
    }

    public void setParentID(String parentid) {
        ParentID = parentid;
    }


    public String getChildID() {
        return ChildID;
    }

    public void setChildID(String childid) {
        ChildID = childid;
    }


    public String getParentcategory() {
        return Parentcategory;
    }

    public void setParentcategory(String parentCategory) {
        Parentcategory = parentCategory;
    }



    public String getHourlyRate() {
        return hourlyRate;
    }

    public void setHourlyRate(String hourly_rate) {
        hourlyRate = hourly_rate;
    }


    public String getlevelOfexp() {
        return levelOfexp;
    }

    public void setlevelOfexp(String levelExp) {
        levelOfexp = levelExp;
    }


    public String getMinHourlyRate() {
        return minRate;
    }

    public void setMinHourlyRate(String minHourlyRate) {
        minRate = minHourlyRate;

    }


    public Boolean Isdatasavethere() {
        return isCategoryDataSaved;
    }

    public void setdatasavethere(Boolean isthere) {
        this.isCategoryDataSaved = isthere;
    }
}
