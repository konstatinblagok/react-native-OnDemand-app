package com.a2zkajuser.pojo;

/**
 * Created by user145 on 2/14/2017.
 */
public class TransactionPojoInfo {

    private String TransactionJobId = "";
    private String TransactionCategoryName = "";
    private String TransactionTotalAmount = "",TransactionDate = "",TransactionTime = "";


    public String getTransactionDate() {
        return TransactionDate;
    }

    public void setTransactionDate(String transactionDate) {
        TransactionDate = transactionDate;
    }

    public String getTransactionTime() {
        return TransactionTime;
    }

    public void setTransactionTime(String transactionTime) {
        TransactionTime = transactionTime;
    }

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

}
