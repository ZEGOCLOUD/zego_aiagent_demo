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

        std::shared_ptr<ISink> basic_file_st(const std::string& filename, bool truncate = false);
        std::shared_ptr<ISink> basic_file_mt(const std::string& filename, bool truncate = false);

    }  // namespace sink

    namespace async_logger
    {
        std::shared_ptr<ILogger> basic_file_st(const std::string& logger_name, const std::string& filename, bool truncate = false);
        std::shared_ptr<ILogger> basic_file_mt(const std::string& logger_name, const std::string& filename, bool truncate = false);

    }  // namespace async_logger
    namespace sync_logger
    {
        std::shared_ptr<ILogger> basic_file_st(const std::string& logger_name, const std::string& filename, bool truncate = false);
        std::shared_ptr<ILogger> basic_file_mt(const std::string& logger_name, const std::string& filename, bool truncate = false);

    }  // namespace sync_logger
}  // namespace factory

}  // namespace zlogger
