package com.a2zkaj.Pojo;

/**
 * Created by user145 on 2/14/2017.
 */
public class TransactionPojoInfo {
    private String TransactionJobId = "";
    private String TransactionCategoryName = "";
    private String TransactionTotalAmount = "";
    private String date="";
    private String time="";

    public String getTransactionJobId() {
        return TransactionJobId;
    }

    public void setTransactionJobId(String transactionJobId) {
        TransactionJobId = transactionJobId;
    }

    public String getTransactionCategoryName() {
        return TransactionCategoryName;
    }

    public void setTransactionCategoryName(String transactionCategoryName) {
        TransactionCategoryName = transactionCategoryName;
    }

    public String getTransactionTotalAmount() {
        return TransactionTotalAmount;
    }

    public void setTransactionTotalAmount(String transactionTotalAmount) {
        TransactionTotalAmount = transactionTotalAmount;
    }

    public void setDate(String date) {
        this.date = date;
    }
    public String getDate() {
        return date;
    }
    public void setTime(String time) {
        this.time = time;
    }
    public String getTime() {
        return time;
    }

}
