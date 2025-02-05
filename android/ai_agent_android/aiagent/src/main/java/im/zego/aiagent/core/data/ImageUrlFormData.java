package im.zego.aiagent.core.data;

import com.google.gson.annotations.SerializedName;

public class ImageUrlFormData {

    public String bucket;
    public String key;
    public String policy;

    @SerializedName("x-amz-algorithm")
    public String x_amz_algorithm;

    @SerializedName("x-amz-credential")
    public String x_amz_credential;

    @SerializedName("x-amz-date")
    public String x_amz_date;

    @SerializedName("x-amz-signature")
    public String x_amz_signature;

}
