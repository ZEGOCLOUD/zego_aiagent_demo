package im.zego.aicompanion.express.log;

import android.content.Context;
import androidx.annotation.NonNull;
import com.elvishew.xlog.XLog;
import com.elvishew.xlog.flattener.ClassicFlattener;
import com.elvishew.xlog.printer.file.FilePrinter;
import com.elvishew.xlog.printer.file.backup.FileSizeBackupStrategy2;
import com.elvishew.xlog.printer.file.clean.FileLastModifiedCleanStrategy;
import com.elvishew.xlog.printer.file.naming.DateFileNameGenerator;
import java.io.File;
import timber.log.Timber;

public class Logger {

    private static boolean showInLogcat = true;
    private static boolean XLogInit = false;

    public static void debugMode(Context context) {
        if (Timber.treeCount() == 0) {
            String logFileDir = context.getExternalFilesDir(null).getAbsolutePath() + File.separator + "uikit_log";
            long logFileExpired = 5 * 24 * 3600 * 1000; // five days
            long logFileMaxSize = 5 * 1024 * 1024; // 5 MB
            FilePrinter filePrinter = new FilePrinter.Builder(logFileDir).fileNameGenerator(new DateFileNameGenerator())
                .cleanStrategy(new FileLastModifiedCleanStrategy(logFileExpired))
                .backupStrategy(new FileSizeBackupStrategy2(logFileMaxSize, 3)).flattener(new ClassicFlattener())
                .build();
            XLog.init(filePrinter);
            XLogInit = true;
        }
        Timber.uprootAll();
        Timber.plant(new Timber.DebugTree() {
            @Override
            protected void log(int priority, String tag, @NonNull String message, Throwable t) {
                if (showInLogcat) {
                    super.log(priority, tag, message, t);
                }
                if (XLogInit) {
                    XLog.tag(tag).log(priority, message, t);
                }
            }
        });
    }

    public static void showInLogcat(boolean show) {
        showInLogcat = show;
    }
}
