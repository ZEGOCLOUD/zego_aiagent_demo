#pragma once

// stl
#include <stdint.h>
#include <cstddef>
#include <functional>
#include <memory>
#include <string>
#include <vector>
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
    namespace sync_logger
    {
        std::shared_ptr<ILogger> multi_sink(const std::string& logger_name, std::vector<ISink_ptr> sinks);
        std::shared_ptr<ILogger> multi_sink(const std::string& logger_name, std::initializer_list<ISink_ptr> sinks);

    }  // namespace sync_logger
    namespace async_logger
    {
        std::shared_ptr<ILogger> multi_sink(const std::string& logger_name, std::vector<ISink_ptr> sinks);
        std::shared_ptr<ILogger> multi_sink(const std::string& logger_name, std::initializer_list<ISink_ptr> sinks);
    }  // namespace async_logger

}  // namespace factory
}  // namespace zlogger
