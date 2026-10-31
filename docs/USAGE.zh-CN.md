# huahua-purge 使用手册

> 适用版本：1.1.71 · 平台：DSH ≥ 0.2.1-rc.2

## 一、装完先验三件事

```bash
# ① 依赖是否写进 profile
#    <DSH_HOME>/profiles/<你的profile>/package.json → dependencies["huahua-purge"]

# ② bundle 是否挂上
#    同一文件 → dsh.profile.bundles 里应有 "huahua-purge"

# ③ patch 文件是否随包到位
#    node_modules/huahua-purge/cordis.patch.yml 必须存在
```

三样缺一样，插件都不会挂载。**改完必须重启宿主**（Ctrl+R 只刷前端）。

## 二、破甲怎么用

### 开关在哪

```
设置 → huahua-purge
```

### 最小可用配置

| 键 | 建议值 | 为什么 |
|---|---|---|
| `enabled` | `true` | 总开关 |
| `autoApplyOnStart` | `true` | 每次启动自动生效，省得手动点 |
| `stripMnemon` | `true` | 清掉记忆注入片段，避免身份回灌 |
| `autoRetry` | `true` + `retryMax: 3` | 被拒自动重试 |
| `hooksDenyBypass` | `true` | 防止模型绕过 hook |

### 逐模型提示词

不同模型对破甲的敏感度不同。配置文件里按模型名分组，各用一套提示词；切换模型时自动跟着换。

## 三、演练台怎么用

### 1. 先设授权边界

演练台第一次运行会要求你确认授权范围（写进 `$DSH_HOME/huahua-purge/drill-grant`）。**没授权不做任何主动扫描**。

### 2. 发一个靶标

```
直接在主会话里发：<你的靶标名称或域名>
```

主会话会拉起五个角色：

```
信息收集 → 资产梳理 → 漏洞发现 → 漏洞利用 → 内网渗透
（并发上限 3，前面的没出结论不会盲目前推）
```

### 3. 看资产库

```
设置 → huahua-purge 演练台 → 资产库
```

数据落在 `$DSH_HOME/huahua-purge/` 下的 SQLite，可以直接用 sqlite3 打开。

### 4. 技能怎么被选中

每个技能 `.md` 顶部有触发条件。角色拉起时按「当前阶段 + 已收资产类型」匹配技能；你也可以直接点名：

```
用 fscan-intranet 这个技能扫一遍
```

## 四、常见问题

### Q1：装了没反应 / 设置里看不到入口

按顺序查：

```
1. bundles 里有 huahua-purge 吗
2. node_modules/huahua-purge/cordis.patch.yml 在吗
3. 重启过宿主吗（不是 Ctrl+R）
4. 宿主控制台有没有 patch apply 报错
```

### Q2：杀软报毒

`skills/redteam/*.md` 里有 payload 代码样例（一句话木马、反弹 shell 一行命令），签名引擎会按 payload 家族命名（如 `Backdoor:PHP/Chopper`）。

**这是文本特征命中，不是可执行后门**。三种处理：

```
A. 给该目录加杀软排除（推荐，保留技能库）
B. 把 .md 里的 payload 改成占位符（保留方法论、丢可直接复制的样例）
C. 不用演练台，只开破甲
```

### Q3：破甲后模型还是带身份

```
1. 看 enabled 是否 true
2. 看 autoApplyOnStart；关着的话要手动点一次「立即破甲」
3. 看 stripMnemon 是否 true（记忆注入会回灌身份）
4. 看 capabilityProtocol 是否被别的插件覆盖了 system prompt
```

### Q4：和别的红队插件冲突吗

本插件的 patch 会主动 `disabled: true` 掉这三个旧包行：

```
dsh-redteam-store · dsh-redteam-ui · dsh-redteam-mode
```

如果你还要用它们，把 `cordis.patch.yml` 里对应的 disabled 段删掉再装。

### Q5：升级会不会冲掉我的数据

```
资产库在   $DSH_HOME/huahua-purge/        ← 不在插件目录内，升级不动
插件本体在 node_modules/huahua-purge/     ← 升级会被覆盖
```

改过插件代码的话，升级前先备份；数据不用备份。

## 五、卸载

```bash
dsh plugin --profile desktop remove huahua-purge
# 重启宿主
# 如需彻底清数据：删掉 $DSH_HOME/huahua-purge/
```

## 六、目录结构

```
huahua-purge/
├── bin/huahua-purge.js        CLI 入口
├── lib/                       宿主侧逻辑（core / identity / redteam / hooks …）
├── client.js                  浏览器侧界面
├── cordis.patch.yml           bundle patch（决定挂哪些行）
├── presets/redteam/           演练台预设（preset.yml + agent.cordis.yml + anchor-gate.mjs）
├── skills/redteam/            23 个实战技能
├── docs/                      文档
└── assets/                    品牌资产
```
