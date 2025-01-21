//
// Created by zego on 2021/12/9.
//

#include "LogUtil.h"
#include "ZLoggerWrapper.h"
#include <fstream>
#include <iostream>

namespace LogIO {
    std::string logmsg;
    void init(std::string &msg,std::string logDirPath) {
        ZLoggerWrapper::getInstance().init(msg, logDirPath);
    }

    void addLogMsg(const std::string &msg) { logmsg += msg; }

    void writeLog(const uint32_t &tag, const int &line, const int &type, const char *module,
                  const char *format) {
        addLogMsg(format);
        ZLoggerWrapper::getInstance().writeLog(tag, line, type, module, logmsg);
        logmsg.clear();
    }

    void samplingLog(const uint32_t &sampleNum, const uint32_t &tag, const int &line,
                     const int &type, const char *module,
                     const char *format) {
        if (sampleNum % SAMPLING_INTERVAL == 0) {
            writeLog(tag, line, type, module, format);
        }
    }
}

