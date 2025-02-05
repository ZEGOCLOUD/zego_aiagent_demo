package im.zego.aiagent.core.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

public class ZipUtils {

    public static void zipFiles(List<String> filePaths, String outputFilePath) throws IOException {
        try (ZipOutputStream zos = new ZipOutputStream(new FileOutputStream(outputFilePath))) {
            for (String filePath : filePaths) {
                File file = new File(filePath);
                if (file.exists()) {
                    addFileToZip(zos, file, "");
                }
            }
        }
    }

    private static void addFileToZip(ZipOutputStream zos, File file, String baseDir) throws IOException {
        if (file.isDirectory()) {
            String dirPath = file.getPath().length() <= baseDir.length() ? baseDir : baseDir + file.getName() + "/";
            ZipEntry zipEntry = new ZipEntry(dirPath);
            zos.putNextEntry(zipEntry);
            zos.closeEntry();

            File[] childFiles = file.listFiles();
            if (childFiles != null) {
                for (File childFile : childFiles) {
                    addFileToZip(zos, childFile, dirPath);
                }
            }
        } else {
            ZipEntry zipEntry = new ZipEntry(baseDir + file.getName());
            zos.putNextEntry(zipEntry);
            try (FileInputStream fis = new FileInputStream(file)) {
                byte[] bytes = new byte[1024];
                int length;
                while ((length = fis.read(bytes)) >= 0) {
                    zos.write(bytes, 0, length);
                }
            }
            zos.closeEntry();
        }
    }

    public static void createZipFile(List<String> filePaths, String outputZipFilePath) {
        try {
            zipFiles(filePaths, outputZipFilePath);
            System.out.println("Zip file created successfully.");
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println("Error occurred while creating zip file.");
        }
    }

    public static List<String> findFilesWithPrefix(String directoryPath, String prefix) {
        File directory = new File(directoryPath);
        List<String> fileList = new ArrayList<>();

        // 检查目录是否存在
        if (directory.exists() && directory.isDirectory()) {
            // 遍历目录下的所有文件和子目录
            File[] files = directory.listFiles();
            if (files != null) {
                for (File file : files) {
                    // 检查是否为文件且文件名以指定前缀开头
                    if (file.isFile() && file.getName().startsWith(prefix)) {
                        fileList.add(file.getAbsolutePath());
                    }
                    //                    // 如果是目录，递归查找
                    else if (file.isDirectory()) {
                        List<String> subFiles = findFilesWithPrefix(file.getAbsolutePath(), prefix);
                        if (!subFiles.isEmpty()) {
                            fileList.addAll(subFiles);
                        }
                    }
                }
            }
        }

        // 将列表转换为数组并返回
        return fileList;
    }
}
