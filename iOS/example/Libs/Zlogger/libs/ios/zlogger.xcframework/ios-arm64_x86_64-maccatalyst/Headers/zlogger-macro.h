#pragma once

#ifndef __ZLOGGER_SIMPLE_FUNC__
#if defined(__ANDROID__) || defined(ANDROID) || defined(_OS_ANDROID_)
#define __ZLOGGER_SIMPLE_FUNC__ __FUNCTION__
#else
#define __ZLOGGER_SIMPLE_FUNC__ __func__
#endif
#endif

/**
 * @brief    无tag日志
 */
#define zlog_trace(logger, fmt, ...)    zlog(logger, 0, zlogger::level::trace, fmt, ##__VA_ARGS__)
#define zlog_debug(logger, fmt, ...)    zlog(logger, 0, zlogger::level::debug, fmt, ##__VA_ARGS__)
#define zlog_info(logger, fmt, ...)     zlog(logger, 0, zlogger::level::info, fmt, ##__VA_ARGS__)
#define zlog_warn(logger, fmt, ...)     zlog(logger, 0, zlogger::level::warn, fmt, ##__VA_ARGS__)
#define zlog_error(logger, fmt, ...)    zlog(logger, 0, zlogger::level::err, fmt, ##__VA_ARGS__)
#define zlog_critical(logger, fmt, ...) zlog(logger, 0, zlogger::level::critical, fmt, ##__VA_ARGS__)

/**
 * @brief    tag日志
 */
#define zlog_t_trace(logger, tag, fmt, ...)    zlog(logger, tag, zlogger::level::trace, fmt, ##__VA_ARGS__)
#define zlog_t_debug(logger, tag, fmt, ...)    zlog(logger, tag, zlogger::level::debug, fmt, ##__VA_ARGS__)
#define zlog_t_info(logger, tag, fmt, ...)     zlog(logger, tag, zlogger::level::info, fmt, ##__VA_ARGS__)
#define zlog_t_warn(logger, tag, fmt, ...)     zlog(logger, tag, zlogger::level::warn, fmt, ##__VA_ARGS__)
#define zlog_t_error(logger, tag, fmt, ...)    zlog(logger, tag, zlogger::level::err, fmt, ##__VA_ARGS__)
#define zlog_t_critical(logger, tag, fmt, ...) zlog(logger, tag, zlogger::level::critical, fmt, ##__VA_ARGS__)

// with format
#define zlog(logger, tag, lvl, fmt, ...) zlogger_write_to(logger, tag, lvl, __ZLOGGER_SIMPLE_FUNC__, __LINE__, fmt, ##__VA_ARGS__)

namespace zlogger
{
void zlogger_write_to(
  std::shared_ptr<ILogger> logger, uint32_t tag, level::level_enum lvl, const char* funcname, int line, const char* fmt, ...);

std::string zlogger_snprintf(const char* fmt, ...);

}  // namespace zlogger