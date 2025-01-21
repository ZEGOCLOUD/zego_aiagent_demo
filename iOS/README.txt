
## 压缩包目录说明

├── SDK                         # SDK包
├── VERSION.txt                 # 版本号, 反馈问题时需要提供, 也可以通过 `ZegoAvatarService` 的 `getVersion` 方法获取到
├── assets
│   ├── AIModel.bundle          # AI模型, 初始化 `ZegoAvatarService` 时使用
│   ├── Packages                # 妆容资源包, 可以放到服务器, 运行时再下载, 调用 `ZegoCharacterHelper` 的 `setExtendPackagePath` 设置
│   ├── base.bundle             # 基础头模资源, 创建 `ZegoCharacterHelper` 时使用
│   ├── emoji.bundle            # 脸基尼头模资源, 创建 `ZegoCharacterHelper` 时使用
│   └── human.bundle            # 基础人模资源, 创建 `ZegoCharacterHelper` 时使用
├── example                     # 示例代码工程, 需要修改 appid 和 appsign 以及 bundleId/applicationId 为自己的数据, 然后把 assets 的资源都更新到工程中的 assets 目录
└── helper                      # `ZegoCharacterHelper` 相关代码文件
