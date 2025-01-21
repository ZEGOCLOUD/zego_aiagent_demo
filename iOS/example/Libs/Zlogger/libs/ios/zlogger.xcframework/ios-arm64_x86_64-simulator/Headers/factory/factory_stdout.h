#pragma once

// stl
#include <stdint.h>
#include <cstddef>
#include <functional>
#include <memory>
#include <string>
#include <vector>

// inner


namespace zlogger
{
class ISink;
class ILogger;

using ILogger_ptr = std::shared_ptr<ILogger>;
using ISink_ptr   = std::shared_ptr<ISink>;
namespace factory
{
    namespace sink
    {
        std::shared_ptr<ISink> stdout_st();
        std::shared_ptr<ISink> stdout_mt();

    }  // namespace sink

    namespace async_logger
    {
        std::shared_ptr<ILogger> stdout_st(const std::string& logger_name);
        std::shared_ptr<ILogger> stdout_mt(const std::string& logger_name);

    }  // namespace async_logger
    namespace sync_logger
    {
        std::shared_ptr<ILogger> stdout_st(const std::string& logger_name);
        std::shared_ptr<ILogger> stdout_mt(const std::string& logger_name);

    }  // namespace sync_logger
}  // namespace factory

}  // namespace zlogger
