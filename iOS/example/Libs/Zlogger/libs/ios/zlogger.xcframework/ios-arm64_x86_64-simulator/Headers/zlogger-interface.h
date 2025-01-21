#pragma once

// stl
#include <functional>
#include <initializer_list>
#include <memory>
#include <string>
#include <vector>

#include "zlogger-defs.h"

namespace zlogger
{
class ISink;
class ILogger;

using ILogger_ptr = std::shared_ptr<ILogger>;
using ISink_ptr   = std::shared_ptr<ISink>;

class ISink
{
  public:  // set
    virtual void set_level(level::level_enum log_level) = 0;
    // virtual void set_pattern(const std::string& pattern)         = 0;
    virtual void set_encrypt_key(const std::string& encrypt_key) = 0;  // 不调用 或 传空 则不加密

  public:  // get
    virtual level::level_enum level() const = 0;

  public:
    virtual ~ISink() = default;
};

class ILogger
{
  public:
    // set functions
    virtual void set_level(level::level_enum log_level) = 0;  // [与sink独立] 都会按level过滤一次
    // virtual void set_pattern(const std::string& pattern) = 0;  // [覆盖所有Sink]
    virtual void set_headinfo(const std::string& headinfo) = 0;  // [覆盖所有Sink] 头部信息，某些时机打印（如：每次轮换文件时）
    virtual void set_encrypt_key(const std::string& encrypt_key) = 0;  // [覆盖所有Sink] 不调用 或 传空 则不加密

    // get functions
    virtual level::level_enum  level() const = 0;
    virtual const std::string& name() const  = 0;  // todo 去掉?

    // write functions
    virtual void write(uint32_t tag, level::level_enum lvl, const char* funcname, int line, const std::string& msg) = 0;
    virtual void write(uint32_t tag, level::level_enum lvl, const char* funcname, int line, std::string&& msg)      = 0;
    virtual void write_raw(level::level_enum lvl, const std::string& msg)                                           = 0;
    virtual void write_raw(level::level_enum lvl, std::string&& msg)                                                = 0;

    // flush functions
    virtual void              flush()                               = 0;
    virtual void              flush_on(level::level_enum log_level) = 0;
    virtual level::level_enum flush_level() const                   = 0;

    // backtrace support.
    // efficiently store all debug/trace messages in a circular buffer until needed for debugging.
    virtual void enable_backtrace(size_t n_messages) = 0;
    virtual void disable_backtrace()                 = 0;
    virtual void dump_backtrace()                    = 0;

  public:
    virtual ~ILogger() = default;
};

}  // namespace zlogger
