#pragma once

#define ZLOGGER_LEVEL_TRACE    0
#define ZLOGGER_LEVEL_DEBUG    1
#define ZLOGGER_LEVEL_INFO     2
#define ZLOGGER_LEVEL_WARN     3
#define ZLOGGER_LEVEL_ERROR    4
#define ZLOGGER_LEVEL_CRITICAL 5
#define ZLOGGER_LEVEL_OFF      6

namespace zlogger
{
namespace level
{
    enum level_enum
    {
        trace    = ZLOGGER_LEVEL_TRACE,
        debug    = ZLOGGER_LEVEL_DEBUG,
        info     = ZLOGGER_LEVEL_INFO,
        warn     = ZLOGGER_LEVEL_WARN,
        err      = ZLOGGER_LEVEL_ERROR,
        critical = ZLOGGER_LEVEL_CRITICAL,
        off      = ZLOGGER_LEVEL_OFF,
        n_levels
    };
}  // namespace level
}  // namespace zlogger
