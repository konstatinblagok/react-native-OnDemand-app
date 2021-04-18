package com.a2zkaj.Pojo;

/**
 * Created by user145 on 2/14/2017.
 */
public class ReviewPojoInfo {

    private String ReviewBookingId = "";
    private String ReviewCategory = "";
    private String ReviewUser = "";
    private String ReviewRating = "";
    private String ReviewDate = "";
    private String ReviewComments = "";
    private String ReviewImage = "";
    private String ReviewUserImage = "";

    public String getReviewBookingId() {
        return ReviewBookingId;
    }

    public void setReviewBookingId(String reviewBookingId) {
        ReviewBookingId = reviewBookingId;
    }

    public String getReviewComments() {
        return ReviewComments;
    }

    public void setReviewComments(String reviewComments) {
        ReviewComments = reviewComments;
    }

    public String getReviewUser() {
        return ReviewUser;
    }

    public void setReviewUser(String reviewUser) {
        ReviewUser = reviewUser;
    }


    public String getUserImage() {
        return ReviewImage;
    }

    public void setUserImage(String reviewImage) {
        ReviewImage = reviewImage;
    }

    public String getReviewImage() {
        return ReviewUserImage;
    }

    public void setReviewImage(String reviewUserImage) {
        ReviewUserImage = reviewUserImage;
    }


    public String getReviewCategory() {
        return ReviewCategory;
    }

    public void setReviewCategory(String reviewCategory) {
        ReviewCategory = reviewCategory;
    }

    public String getReviewRating() {
        return ReviewRating;
    }

    public void setReviewRating(String reviewRating) {
        ReviewRating = reviewRating;
    }

    public String getReviewDate() {
        return ReviewDate;
    }

    public void setReviewDate(String reviewDate) {
        ReviewDate = reviewDate;
    }
}
