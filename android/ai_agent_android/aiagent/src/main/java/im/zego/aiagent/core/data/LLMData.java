package im.zego.aiagent.core.data;

public class LLMData {

    public String Type;
    public String Model;
    public String ExtensionLLMParams;

    @Override
    public String toString() {
        return "LLMData{" +
            "Type='" + Type + '\'' +
            ", Model='" + Model + '\'' +
            ", ExtensionLLMParams='" + ExtensionLLMParams + '\'' +
            '}';
    }
}
