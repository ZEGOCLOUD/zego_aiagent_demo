//
// Created by zego on 2024/12/9.
//

#ifndef __AIAGENT_LOGUTIL_H_
#define __AIAGENT_LOGUTIL_H_

#pragma once //

#include <sstream>
#include <string>
namespace LogIO {

#ifndef __TAG__
#define __TAG__ 0
#endif
#define __AIAGENT_MODULE__ "AIAGENT"
#if DEBUG
#define LOGD(...) LogIO::writeLog(__TAG__, __LINE__, 1, __AIAGENT_MODULE__, __VA_ARGS__)
#else
#define LOGD(...)
#endif

#define LOGI(...) LogIO::writeLog(__TAG__, __LINE__, 2, __AIAGENT_MODULE__, __VA_ARGS__)
#define LOGW(...) LogIO::writeLog(__TAG__, __LINE__, 3, __AIAGENT_MODULE__, __VA_ARGS__)
#define LOGE(...) LogIO::writeLog(__TAG__, __LINE__, 4, __AIAGENT_MODULE__, __VA_ARGS__)

    //抽样日志
#define SAMPLING_INTERVAL 120
#define LOGS(sampling, ...) samplingLog(sampling, __TAG__, __LINE__, 2, __AIAGENT_MODULE__, __VA_ARGS__)

    void init(std::string &msg, std::string logDirPath = "");
    void addLogMsg(const std::string &msg);
    void writeLog(const uint32_t &tag, const int &line, const int &type, const char *module,
                  const char *format);
    template<typename... Ts>
    void empty(Ts &&... args) {
    }

    template<typename T, typename... Ts>
    void writeLog(const uint32_t &tag, const int &line, const int &type, const char *module,
                  const char *format, T &&value, Ts &&... args) {
        for (; *format != '\0'; ++format) {
            if (*format == '%') {
                std::stringstream ss;
                ss << value;
                addLogMsg(ss.str());
                writeLog(tag, line, type, module, format + 2, std::forward<Ts>(args)...);
                return;
            }
            char tmpc = *format;
            std::string tmps;
            tmps += tmpc;
            addLogMsg(tmps);
        }
    }

    void samplingLog(const uint32_t &sampleNum, const uint32_t &tag, const int &line,
                     const int &type, const char *module,
                     const char *format);
    template<typename T, typename... Ts>
    void samplingLog(const uint32_t &sampleNum, const uint32_t &tag, const int &line,
                     const int &type, const char *module,
                     const char *format, T &&value, Ts &&... args) {
        if (sampleNum % SAMPLING_INTERVAL == 0) {
            std::string moduleStr = std::string(module) + ":" + std::to_string(sampleNum);
            writeLog(tag, line, type, moduleStr.c_str(), format, value,
                     std::forward<Ts>(args)...);
        }
    }
}

#endif

