package im.zego.aiagent.core.data;

/**
 * 后台交互数据，向后台上传图片得到的数据返回，包含url 地址。示例：
 *
 * {
 *     "Code": 0,
 *     "Message": "Succeed",
 *     "RequestId": "1855952161108660224",
 *     "Data": {
 *         "PostUrl": "https://zego-aigc-test.oss-accelerate.aliyuncs.com/",
 *         "FullUrl": "https://zego-aigc-test.oss-accelerate.aliyuncs.com/20241111%2F1855952161112854528.jpg?Expires=1731328451&OSSAccessKeyId=LTAI5tGqv9rje9rHtTDWyDXo&Signature=uxWmLWfOzmWo89WuoauJiF9gFjI%3D&response-content-disposition=attachment%3B%20filename%3D20241111%2F1855952161112854528.jpg",
 *         "FormData": {
 *             "bucket": "zego-aigc-test",
 *             "key": "20241111/1855952161112854528.jpg",
 *             "policy": "eyJleHBpcmF0aW9uIjoiMjAyNC0xMS0xMVQxNTozNDoxMS43ODhaIiwiY29uZGl0aW9ucyI6W1siZXEiLCIkYnVja2V0IiwiemVnby1haWdjLXRlc3QiXSxbImVxIiwiJGtleSIsIjIwMjQxMTExLzE4NTU5NTIxNjExMTI4NTQ1MjguanBnIl0sWyJlcSIsIiR4LWFtei1kYXRlIiwiMjAyNDExMTFUMTIzNDExWiJdLFsiZXEiLCIkeC1hbXotYWxnb3JpdGhtIiwiQVdTNC1ITUFDLVNIQTI1NiJdLFsiZXEiLCIkeC1hbXotY3JlZGVudGlhbCIsIkxUQUk1dEdxdjlyamU5ckh0VERXeURYby8yMDI0MTExMS9vc3MtY24tc2hhbmdoYWkvczMvYXdzNF9yZXF1ZXN0Il0sWyJjb250ZW50LWxlbmd0aC1yYW5nZSIsIDEsIDMxNDU3MjgwXV19",
 *             "x-amz-algorithm": "AWS4-HMAC-SHA256",
 *             "x-amz-credential": "LTAI5tGqv9rje9rHtTDWyDXo/20241111/oss-cn-shanghai/s3/aws4_request",
 *             "x-amz-date": "20241111T123411Z",
 *             "x-amz-signature": "498cfea7d1301fda307140da72541099d2eec22e9f08d360ffa6dd9a23c5a9ed"
 *         }
 *     }
 * }
 */
public class ImageUrlData {

    public String PostUrl;
    public String FullUrl;
    public ImageUrlFormData FormData;

    public boolean isValid() {
        return true;
    }

    @Override
    public String toString() {
        return "ImageUrlData{" +
            "PostUrl='" + PostUrl + '\'' +
            ", FullUrl='" + FullUrl + '\'' +
            ", FormData=" + FormData +
            '}';
    }
}
