# 初始化脚本失败

---

①打开日志查看错误详情信息

![img](https://ae04.alicdn.com/kf/Hed30bab9cbd44da8b50f9dab38d0b9eex.png)

②从日志可以看到错误原因是 **PanData/script/lib/lcurl.dll** 这个文件找不到

![img](https://ae04.alicdn.com/kf/Hb03acbc0b9ff4818bc3ffbdbff32e93dA.png)

③打开 **PanData/script/lib** 文件夹，检查一下 **lcurl.dll** 是否存在，如果不存在有可能是被杀毒软件当成病毒删除了，从官网重新下载，添加信任再运行即可

④如果这个文件存在还是有错误，可能是文件路径包含中文，请把路径改成全英文再试试

