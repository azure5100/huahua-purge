# 来源与衍生声明 / Provenance Notice

## 上游

```
项目    dsh-purge
版本    1.1.71
仓库    https://github.com/YuJunZhiXue/dsh-purge
许可    MIT · Copyright (c) 2026 小杨
```

## 本仓库做了什么

`huahua-purge` 是 `dsh-purge` 1.1.71 的衍生版，改动范围：

| 类别 | 改动 |
|---|---|
| 包身份 | `dsh-purge` → `huahua-purge`；CLI 命令名同步；`cordis.patch.yml` 里的 `name:` 全部对齐新包名 |
| 内部标识 | 源码中 838 处 `dsh-purge` 字符串统一替换为 `huahua-purge`（含存储路径、hook 标记、client loader id），保证新包与旧包并存时互不串数据 |
| 运行时数据目录 | `$DSH_HOME/dsh-purge` → `$DSH_HOME/huahua-purge` |
| 文档 | 新增中文 README、英文 README、使用手册、来源声明 |
| 品牌资产 | 新增 `assets/icon.svg`、`assets/banner.svg`（huahua 七色光花蕊）|
| 清理 | 移除上游包内的 `.bak` 备份与 `screenshots.json` |

**未改动**：插件功能、破甲策略、技能库内容、演练台架构。

## 版权归属

- 上游代码：Copyright (c) 2026 小杨，MIT
- 衍生改动与新增文档/品牌资产：Copyright (c) 2026 huahua，MIT

两份版权声明都保留在 [LICENSE](LICENSE) 里，符合 MIT 对衍生作品的要求。

## 与上游并存

`huahua-purge` 与 `dsh-purge` 是**两个不同包**，插件 id 与数据目录都不重叠，理论上可同时安装。**但不要同时启用**：两者都会修改全局 `system-prompt` 并禁用旧红队包行，同时生效会互相覆盖。
