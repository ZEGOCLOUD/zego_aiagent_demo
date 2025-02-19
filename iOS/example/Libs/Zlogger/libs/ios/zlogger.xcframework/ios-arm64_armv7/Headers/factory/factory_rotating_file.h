#pragma once

// stl
#include <stdint.h>
#include <cstddef>
#include <functional>
#include <memory>
#include <string>
#include <vector>

// inner


// todo  补充mt/st async/sync的说明 以及相应的benchmark到头文件中

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

        
      
        std::shared_ptr<ISink> rotating_file_st(
          const std::string& filename, std::size_t max_size, std::size_t max_files, bool rotate_on_open = false);

        std::shared_ptr<ISink> rotating_file_mt(
          const std::string& filename, std::size_t max_size, std::size_t max_files, bool rotate_on_open = false);
    }  // namespace sink

    namespace async_logger
    {
        std::shared_ptr<ILogger> rotating_file_st(const std::string& logger_name, const std::string& filename, std::size_t max_size,
          std::size_t max_files, bool rotate_on_open = false);

        std::shared_ptr<ILogger> rotating_file_mt(const std::string& logger_name, const std::string& filename, std::size_t max_size,
          std::size_t max_files, bool rotate_on_open = false);
    }  // namespace async_logger

    namespace sync_logger
    {
        std::shared_ptr<ILogger> rotating_file_st(const std::string& logger_name, const std::string& filename, std::size_t max_size,
          std::size_t max_files, bool rotate_on_open = false);

        std::shared_ptr<ILogger> rotating_file_mt(const std::string& logger_name, const std::string& filename, std::size_t max_size,
          std::size_t max_files, bool rotate_on_open = false);
    }  // namespace sync_logger

}  // namespace factory

}  // namespace zlogger
