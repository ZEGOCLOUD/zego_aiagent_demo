package im.zego.aiagent.core.data;

public class ExtensionParams {
    public String Cluster;
    public String ApiType;
    public String ResourceId;

    @Override
    public String toString() {
        return "ExtensionParams{" +
            "Cluster='" + Cluster + '\'' +
            ", ApiType='" + ApiType + '\'' +
            ", ResourceId='" + ResourceId + '\'' +
            '}';
    }
}
