# DeepSeek Harness Launcher / 启动器

Windows 下的一键 **启动 / 停止** [DeepSeek Harness](https://www.npmjs.com/package/@deepseek-ai/dsh) Web 界面（`dsh web`）的小工具。

A Windows one-click **toggle** for the [DeepSeek Harness](https://www.npmjs.com/package/@deepseek-ai/dsh) Web UI (`dsh web`).

同一个快捷方式即可切换两种状态 / One shortcut does both jobs:

- **未运行时**：后台静默启动 `dsh web`，等端口就绪后自动打开浏览器。
  **Not running**: start `dsh web` hidden, wait for the port, then open the browser.
- **已运行时**：自动停止整个 dsh 进程族，不残留后台进程。
  **Running**: stop the whole dsh process family, leaving nothing behind.

## 特性 / Features

- 🪟 无控制台窗口（VBS 静默调用 PowerShell） / No console window (VBS invokes PowerShell silently)
- 🔍 自动定位 `dsh` 命令：优先全局 npm 安装，回退到 npx 缓存 / Auto-locates the `dsh` command: global npm install first, npx cache as fallback
- ⏳ 智能等待端口就绪（最长 30 秒） / Waits for the port to be ready (up to 30 seconds)
- 🎯 停止时精确匹配 dsh 进程，不误杀其它 Node 应用 / Stops only dsh processes, never unrelated Node apps
- 📦 位置无关：整个文件夹可随意移动、复制或克隆 / Location-independent: move, copy or clone the folder anywhere

## 环境要求 / Requirements

- Windows 10 / 11
- Node.js（含 npm）
- 已全局安装 DeepSeek Harness / DeepSeek Harness installed globally:

  ```powershell
  npm install -g @deepseek-ai/dsh
  ```

## 使用方法 / Usage

**方式一（推荐）**：双击 `harness.vbs` —— 无窗口，适合日常使用。
**Option 1 (recommended)**: double-click `harness.vbs` — no window, for everyday use.

**方式二**：在 PowerShell 中运行 / **Option 2**: run in PowerShell:

```powershell
.\harness.ps1               # 默认端口 3080，切换启动 / 停止
                            # default port 3080, toggles start / stop
.\harness.ps1 -Port 8080    # 指定其它端口 / use a different port
```

## 创建桌面快捷方式 / Desktop Shortcut

```powershell
.\install.ps1           # 在桌面创建 “DeepSeek Harness” 快捷方式（带图标）
                        # create a desktop shortcut with icon
.\install.ps1 -Remove   # 删除该快捷方式 / remove the shortcut
```

## 文件说明 / Files

| 文件 / File | 说明 / Description |
| --- | --- |
| `harness.ps1` | 主脚本：检测端口、启动、等待、停止 / main script: probe, start, wait, stop |
| `harness.vbs` | 无窗口入口，供快捷方式调用 / windowless entry, used by the shortcut |
| `install.ps1` | 一键创建 / 删除桌面快捷方式 / create or remove the desktop shortcut |
| `icon.ico` | 快捷方式图标 / shortcut icon |

## 工作原理 / How It Works

1. 检测 `127.0.0.1:3080`（或 `-Port` 指定端口）是否已有服务在监听 / Probe whether something listens on `127.0.0.1:3080` (or the `-Port` value);
2. 未运行 → 找到 `dsh` 命令并以隐藏窗口启动 `dsh web`，轮询等待端口就绪后打开浏览器 / Not running → locate `dsh`, start `dsh web` hidden, poll until the port is ready, then open the browser;
3. 已运行 → 根据进程命令行匹配 `@deepseek-ai\dsh` 的 node 进程 + 端口监听进程，强制结束并校验 / Running → match node processes by command line plus the port listener, force-stop, and verify.

## 许可 / License

[MIT](LICENSE)
