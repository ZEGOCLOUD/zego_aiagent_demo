package im.zego.aiagent.core.data;

public class TTSData {

    public String Type;
    public String Voice;
    public ExtensionParams ExtensionParams;

    @Override
    public String toString() {
        return "TTSData{" +
            "Type='" + Type + '\'' +
            ", Voice='" + Voice + '\'' +
            ", ExtensionParams=" + ExtensionParams +
            '}';
    }
}
