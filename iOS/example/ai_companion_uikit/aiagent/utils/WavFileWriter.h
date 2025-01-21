#pragma once

#include <functional>
#include <string>

class  WavFileWriter {
public:
    WavFileWriter();
    ~WavFileWriter();
    /// <summary>
    /// 创建wav文件
    /// </summary>
    /// <param name="fileName">文件名</param>
    /// <param name="channels">声道数</param>
    /// <param name="sampleRate">采样率，单位hz</param>
    /// <param name="bitsPerSample">位深</param>
    void CreateWavFile(const std::string& fileName, int channels, int  sampleRate, int  bitsPerSample);
    /// <summary>
    /// 写入PCM数据
    /// </summary>
    /// <param name="data">PCM数据</param>
    /// <param name="dataLength">数据长度</param>
    void WriteToFile(unsigned char* data, int dataLength);
    /// <summary>
    /// 关闭文件
    /// </summary>
    void CloseFile();
private:
    void* _file = nullptr;
    uint32_t _totalDataLength = 0;
    int _channels;
    int _sampleRate;
    int _bitsPerSample;
};

