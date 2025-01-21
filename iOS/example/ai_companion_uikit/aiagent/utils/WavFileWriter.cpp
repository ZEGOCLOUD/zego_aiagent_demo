#define _CRT_SECURE_NO_WARNINGS
#include "WavFileWriter.h"


//WAV头部结构-PCM格式
struct WavPCMFileHeader
{
    struct RIFF {
        const	char rift[4] = { 'R','I', 'F', 'F' };
        uint32_t fileLength;
        const	char wave[4] = { 'W','A', 'V', 'E' };
    }riff;
    struct Format
    {
        const	char fmt[4] = { 'f','m', 't', ' ' };
        uint32_t blockSize = 16;
        uint16_t formatTag;
        uint16_t channels;
        uint32_t samplesPerSec;
        uint32_t avgBytesPerSec;
        uint16_t blockAlign;
        uint16_t  bitsPerSample;
    }format;
    struct  Data
    {
        const	char data[4] = { 'd','a', 't', 'a' };
        uint32_t dataLength;
    }data;
    WavPCMFileHeader() {}
    WavPCMFileHeader(int nCh, int  nSampleRate, int  bitsPerSample, int dataSize) {
        riff.fileLength = 36 + dataSize;
        format.formatTag = 1;
        format.channels = nCh;
        format.samplesPerSec = nSampleRate;
        format.avgBytesPerSec = nSampleRate * nCh * bitsPerSample / 8;
        format.blockAlign = nCh * bitsPerSample / 8;
        format.bitsPerSample = bitsPerSample;
        data.dataLength = dataSize;
    }
};
WavFileWriter::WavFileWriter()
{
}

WavFileWriter::~WavFileWriter()
{
    CloseFile();
}
void WavFileWriter::CreateWavFile(const std::string& fileName, int channels, int sampleRate, int bitsPerSample)
{
    if (!_file)
    {
        _channels = channels;
        _sampleRate = sampleRate;
        _bitsPerSample = bitsPerSample;
        _totalDataLength = 0;
        _file = fopen(fileName.c_str(), "wb+");
        //预留头部位置
        fseek(static_cast<FILE*>(_file), sizeof(WavPCMFileHeader), SEEK_SET);
    }
}
void WavFileWriter::WriteToFile(unsigned char* data, int dataLength)
{
    fwrite(data, 1, dataLength, static_cast<FILE*>(_file));
    _totalDataLength += dataLength;
}
void WavFileWriter::CloseFile()
{
    if (_file)
    {
        if (_totalDataLength > 0)
        {
            //写入头部信息
            fseek(static_cast<FILE*>(_file), 0, SEEK_SET);
            WavPCMFileHeader h(_channels, _sampleRate, _bitsPerSample, _totalDataLength);
            fwrite(&h, 1, sizeof(h), static_cast<FILE*>(_file));
        }
        fclose(static_cast<FILE*>(_file));
        _file = nullptr;
    }
}
