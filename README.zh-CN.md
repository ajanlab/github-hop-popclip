# GitHub Hop

[English](./README.md) | 中文

划词一键直达 GitHub 仓库首页。选中项目名 → 直达 GitHub。

## 功能

- **`owner/repo` 格式**（如 `facebook/react`）→ 零延迟直跳仓库页
- **项目名**（如 `lodash`）→ GitHub Search API 智能解析 → 跳转最佳匹配仓库
- **作者名**（如 `@ajanlab`）→ 自动去 `@` 后搜索
- **兜底** → API 失败/限流/超时 → 自动降级到 GitHub 搜索结果页

## 安装

1. 从 [Releases 页面](https://github.com/ajanlab/github-hop-popclip/releases) 下载最新的 `github-hop.popclipextz`
2. 双击安装到 PopClip
3. 选中任意文本 → 点击 PopClip 工具栏的 GitHub 图标

系统要求：macOS 10.15+，PopClip 2023+

## 工作原理

```
选中文本 → 清洗(去引号/去@) → owner/repo? ─是→ 直跳 (0ms)
                                └否→ API 请求 (5s 超时)
                                      ├─ 精确匹配 → 仓库页
                                      ├─ 智能匹配 → 仓库页
                                      └─ 失败/限流 → 搜索页
```

## 隐私说明

- **不上传任何数据**：仅向 GitHub 公开 API 发送你通过 PopClip 主动选中的文本
- **不收集分析数据**：无遥测、无埋点、无第三方端点
- **不存储任何信息**：无缓存文件、无日志、无状态
- **不需要任何权限**：无需 API 密钥、无需登录、无需网络授权（PopClip 自动处理）
- **依赖零外部包**：仅使用 macOS 内置工具（bash, python3, curl, open）

## 验证

从命令行测试（无需 PopClip）：

```bash
# 1. 测试 owner/repo 直跳（零延迟）
export POPCLIP_TEXT="facebook/react"
./github-hop.popclipext/Source/github-hop.sh
# 预期：直接打开 https://github.com/facebook/react

# 2. 测试项目名 API 解析
export POPCLIP_TEXT="lodash"
./github-hop.popclipext/Source/github-hop.sh
# 预期：API 查询后打开 https://github.com/lodash/lodash

# 3. 测试 @ 用户名解析
export POPCLIP_TEXT="@ajanlab"
./github-hop.popclipext/Source/github-hop.sh
# 预期：自动去掉 @，搜索 "ajanlab"

# 4. 测试不存在项目（兜底降级）
export POPCLIP_TEXT="this-project-does-not-exist-12345"
./github-hop.popclipext/Source/github-hop.sh
# 预期：API 无结果，打开 GitHub 搜索页

# 5. 测试空输入
export POPCLIP_TEXT=""
./github-hop.popclipext/Source/github-hop.sh
# 预期：退出码 1，无浏览器动作

# 6. 完整自动化测试
chmod +x test.sh && ./test.sh
```

## 环境变量

| 变量 | 来源 | 说明 |
|---|---|---|
| `POPCLIP_TEXT` | PopClip 注入 | 用户选中的文本（必须） |

无需任何 API 密钥或令牌。本扩展无外部依赖、无需注册、无需配置。

## 开源许可

MIT License — 可自由使用、修改、分发。
