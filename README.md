mulitfilesync
===

批量部署或获取 多台设备上文件的脚本

## 配置文件的格式

host | usr | pw | src_dir | dst_dir
-- | --- | -- | --- | ---
192.168.1.144 | root | 123456 | local file | remote file
192.168.1.144 | root | 123456 | local dir  | remote dir
> **Note.**
> - 文件夹的同步需要根据同步工具自身的文件夹格式填写到配置文件中
