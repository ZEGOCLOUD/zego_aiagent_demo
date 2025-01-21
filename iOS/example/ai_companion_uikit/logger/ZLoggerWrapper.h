//
// Created by zego on 2021/12/9.
//

#pragma once
#include "zlogger-all.h"
#include <algorithm>
#include <iostream>
#include <string>
#include <sstream>

class ZLoggerWrapper {
public:
    ~ZLoggerWrapper();
    static ZLoggerWrapper &getInstance() {
        static ZLoggerWrapper m_instance;
        return m_instance;
    }
    void init(std::string& headInfo,std::string logDirPath);
    
    std::vector<std::string> split(const std::string &str, const std::string &pattern)
    {
        std::vector<std::string> res;
        if("" == str) return res;
        //先将要切割的字符串从string类型转换为char*类型
        char * strs = new char[str.length() + 1] ; //不要忘了
        strcpy(strs, str.c_str());

        char * d = new char[pattern.length() + 1];
        strcpy(d, pattern.c_str());

        char *p = strtok(strs, d);
        while(p) {
            std::string s = p; //分割得到的字符串转换为string类型
            res.push_back(s); //存入结果数组
            p = strtok(NULL, d);
        }

        return res;
    }


    inline void writeLog(const uint32_t &tag, const int &line, const int &type, const char *module,
                         const std::string &message) {
        if(!_enable){
            return;
        }
        auto write = [&](const uint32_t &tmp_tag, const int &tmp_line, const int &tmp_type,
                         const char *tmp_module, const std::string &tmp_message) {
            zlogger::level::level_enum logLevel = static_cast<zlogger::level::level_enum>(tmp_type);
            std::vector<std::string> temp;
            _logWriter->write(tmp_tag, logLevel, tmp_module, tmp_line, tmp_message);
        };

        if (shouldClearBuffer()) {
            //return;
            for_each(std::cbegin(_buffer), std::cend(_buffer), [&](const std::string &str) {
                std::vector<std::string> strVector = split(str, ";");
                if (strVector.size() == 5) {
                    uint32_t tmp_tag = std::stoi(strVector.at(0));
                    int tmp_line = std::stoi(strVector.at(1));
                    int tmp_type = std::stoi(strVector.at(2));
                    write(tmp_tag, tmp_line, tmp_type, strVector.at(3).c_str(), strVector.at(4));
                }
            });
            _buffer.erase(_buffer.begin(), _buffer.end());
        }
        if (_logWriter) {
            write(tag, line, type, module, message);
        } else {
            std::string tmp = std::to_string(tag) + ";" + std::to_string(line) + ";" +
                              std::to_string(type) + ";" + std::string(module) + ";" + message;
            _buffer.push_back(tmp);
        }
    }

    void setEnable(bool enable){
        _enable = enable;
        if(_logWriter) {
            std::ostringstream os1;
            os1 << "log enable:" << enable;
            std::vector<std::string> temp;
            temp.push_back(std::to_string(0));
            
            _logWriter->write(0, zlogger::level::level_enum::info, "ZA", 0, std::string(os1.str()));
            _logWriter->flush();
        }
    }

private:
    ZLoggerWrapper();
    inline bool shouldClearBuffer() {
        return _logWriter && _buffer.size() > 0;
    }

private:
    std::shared_ptr<zlogger::ILogger> _logWriter;
    std::shared_ptr<zlogger::ISink> _consoleSink;
    std::shared_ptr<zlogger::ISink> _rotatingSink;
    std::vector<std::string> _buffer;
    
    std::string log_file_name_;
    std::string log_encrypt_key_;
    std::size_t log_max_files_;


    bool _enable = true;
};


