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
        std::shared_ptr<ISink> daily_file_st(
          const std::string& filename, int rotation_hour = 4, int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);
        std::shared_ptr<ISink> daily_file_mt(
          const std::string& filename, int rotation_hour = 4, int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);

    }  // namespace sink

    namespace async_logger
    {
        std::shared_ptr<ILogger> daily_file_st(const std::string& logger_name, const std::string& filename, int rotation_hour = 4,
          int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);
        std::shared_ptr<ILogger> daily_file_mt(const std::string& logger_name, const std::string& filename, int rotation_hour = 4,
          int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);

    }  // namespace async_logger
    namespace sync_logger
    {
        std::shared_ptr<ILogger> daily_file_st(const std::string& logger_name, const std::string& filename, int rotation_hour = 4,
          int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);
        std::shared_ptr<ILogger> daily_file_mt(const std::string& logger_name, const std::string& filename, int rotation_hour = 4,
          int rotation_minute = 0, bool truncate = false, uint16_t max_files = 0);

    }  // namespace sync_logger
}  // namespace factory

}  // namespace zlogger
