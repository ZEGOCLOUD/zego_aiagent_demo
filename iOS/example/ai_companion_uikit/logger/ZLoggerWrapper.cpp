//
// Created by zego on 2021/12/9.
//

#include "ZLoggerWrapper.h"
#include <fstream>
ZLoggerWrapper::ZLoggerWrapper() {
    log_file_name_ = "AIPeibanLog.txt";
    log_encrypt_key_ = "ljc";
    log_max_files_ = 3;
}

ZLoggerWrapper::~ZLoggerWrapper() {}

void ZLoggerWrapper::init(std::string& headInfo,std::string logDirPath) {
    if(!_logWriter)
    {
        
        _consoleSink = zlogger::factory::sink::stdout_mt();
#if LOG_TO_CONSOLE
        _consoleSink->set_level(zlogger::level::level_enum::debug);
#else
        _consoleSink->set_level(zlogger::level::level_enum::warn);
#endif
        std::string realLogFileName = "";
        realLogFileName = logDirPath + "/ZaLog.txt";

        std::ofstream file(realLogFileName, std::fstream::out);
        if (file){
            _rotatingSink = zlogger::factory::sink::rotating_file_mt(realLogFileName,20 * 1024 * 1024,3, false);
            _logWriter = zlogger::factory::async_logger::multi_sink("Zalog",{_consoleSink, _rotatingSink});
        } else { //文件非法
            _logWriter = zlogger::factory::async_logger::multi_sink("Zalog",{_consoleSink});
        }

        _logWriter->set_encrypt_key("ljc");
        _logWriter->set_level(zlogger::level::level_enum::debug);
        if (!headInfo.empty()) {
            _logWriter->set_headinfo(headInfo);
        }
    }
}
