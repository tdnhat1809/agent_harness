# 逆向工具索引

- 扫描时间: 2026-08-13 23:19:04 +07:00
- 路由入口: `SKILL.md` → `routing.md` → 对应子 skill
- 说明: 本表由 `skills/scripts/refresh-tool-index.ps1` 自动生成，优先用于 Claude 路由和工具路径确认。
- 注意: 对于 jshookmcp 这类 MCP server，`yes` 只表示本机具备通过 node/npx 拉起它的条件，不表示它已经在 MCP 配置里注册并启用。

| 工具 | 归属 skill | 作用 | 可用 | 路径 | 版本 | 来源 | 脚本引用 |
|---|---|---|---|---|---|---|---|
| jadx | apk-reverse | Java 反编译 | no | — | — | Missing | apk-reverse/scripts/decode.ps1 |
| apktool | apk-reverse | APK 解包与重建 | no | — | — | Missing | apk-reverse/scripts/decode.ps1<br>apk-reverse/scripts/rebuild-sign-install.ps1 |
| adb | apk-reverse | 设备连接与 logcat | no | — | — | Missing | apk-reverse/scripts/rebuild-sign-install.ps1 |
| java | apk-reverse | 运行 jar 与 Java 工具链 | no | — | — | Missing | apk-reverse/scripts/decode.ps1 |
| apksigner | apk-reverse | APK 签名 | no | — | — | Missing | apk-reverse/scripts/rebuild-sign-install.ps1 |
| zipalign | apk-reverse | APK 对齐 | no | — | — | Missing | apk-reverse/scripts/rebuild-sign-install.ps1 |
| frida | apk-reverse | Frida 动态注入 | no | — | — | Missing | apk-reverse/scripts/frida-run.ps1 |
| frida-ps | apk-reverse | Frida 进程枚举 | no | — | — | Missing | apk-reverse/scripts/frida-run.ps1 |
| r2 | radare2 | radare2 主分析器 | no | — | — | Missing | radare2/scripts/recon.ps1 |
| rabin2 | radare2 | 二进制侦察 | no | — | — | Missing | radare2/scripts/recon.ps1 |
| rasm2 | radare2 | 汇编/反汇编 | no | — | — | Missing | radare2/SKILL.md |
| radiff2 | radare2 | 二进制差分 | no | — | — | Missing | radare2/SKILL.md |
| rahash2 | radare2 | 哈希与校验 | no | — | — | Missing | radare2/SKILL.md |
| rax2 | radare2 | 进制与位运算转换 | no | — | — | Missing | radare2/SKILL.md |
| python | reverse-engineering | 辅助脚本执行 | yes | C:\Users\minhn\AppData\Local\Programs\Python\Python312\python.exe | — | Get-Command | apk-reverse/scripts/frida-run.ps1<br>case-review/scripts/review_case.py |
| pip | reverse-engineering | Python 包管理 | yes | C:\Users\minhn\AppData\Local\Programs\Python\Python312\Scripts\pip.exe | — | Get-Command | — |
| node | js-reverse | 运行 Node 侧 JS 复现与 MCP 客户端 | yes | C:\Program Files\nodejs\node.exe | — | Get-Command | js-reverse/SKILL.md |
| npx | js-reverse | 运行临时 npm 包与 MCP 入口 | yes | C:\Program Files\nodejs\npx.cmd | — | Get-Command | js-reverse/SKILL.md |
| jshookmcp | js-reverse | 通过 npx 启动 @jshookmcp/jshook MCP（仍需先配置并启用 MCP server） | yes | C:\Program Files\nodejs\npx.cmd | — | Get-Command | js-reverse/SKILL.md |
| reqable-mcp | pentest-tools | 通过 npx 启动 Reqable 桌面客户端 MCP（仍需先安装并启动 Reqable） | yes | C:\Program Files\nodejs\npx.cmd | — | Get-Command | pentest-tools/SKILL.md |
| agent-browser | browser-automation | 浏览器自动化（Playwright）：打开页面、点击、填表、爬取、截图 | no | — | — | Missing | browser-automation/SKILL.md |
| analyzeHeadless | reverse-engineering | Ghidra 无头分析（免费 IDA 替代） | no | — | — | Missing | reverse-engineering/SKILL.md |
| jeb-pro | apk-reverse | JEB Pro 商业 Android / ARM 反编译器（需用户自备有效许可证） | no | — | — | Missing | apk-reverse/SKILL.md |
| playwright | browser-automation | Playwright 浏览器引擎 | no | — | — | Missing | browser-automation/SKILL.md<br>browser-automation/scripts/setup.ps1 |
| proxycat | pentest-tools | 代理池管理与轮换 | no | — | — | Missing | pentest-tools/SKILL.md |
| seclists | pentest-tools | Security wordlists | no | — | — | Missing | pentest-tools/SKILL.md |
| pentestswarm | pentest-tools | 群体智能自主渗透与 MCP 执行 | no | — | — | Missing | pentest-tools/SKILL.md |
| nmap | pentest-tools | 端口扫描与服务识别 | no | — | — | Missing | pentest-tools/SKILL.md |
| binwalk | firmware-pentest | 固件提取与分析 | no | — | — | Missing | firmware-pentest/SKILL.md |
| yara | malware-analysis | 恶意软件规则匹配引擎 | no | — | — | Missing | malware-analysis/SKILL.md |
| pwntools | reverse-engineering | CTF pwn 利用开发框架 | no | — | — | Missing | reverse-engineering/SKILL.md<br>reverse-engineering/patterns-ctf*.md |
| bkcrack | reverse-engineering | CTF ZIP/PKZIP ZipCrypto 已知明文攻击 | no | — | — | Missing | reverse-engineering/crypto-decode-tools.md<br>../CTF-Sandbox-Orchestrator/competition-zip-archive/SKILL.md |


---

## 能力状态视图 (Capability Status)

| 能力 | 工具可用 | Ready | MCP 已注册 | 服务在线 | MCP HTTP | 可自动安装 | 安装方式 |
|------|---------|-------|-----------|---------|-----------|---------|
| jadx | ✗ | ✗ | — | — | — | ✓ | github-release-zip |
| apktool | ✗ | ✗ | — | — | — | ✓ | github-release-jar-wrapper |
| jeb-pro | ✗ | ✗ | — | — | — | ✗ | manual |
| frida | ✗ | ✗ | — | — | — | ✓ | pip-package |
| frida-ps | ✗ | ✗ | — | — | — | ✓ | pip-package |
| idalib-mcp | ✗ | ✗ | — | — | — | ✓ | pip-package |
| jshookmcp | ✓ | ✗ | — | — | — | ✓ | npm-mcp |
| reqable-mcp | ✓ | ✗ | — | — | — | ✓ | npm-mcp |
| anything-analyzer | ✗ | ✗ | — | — | — | ✓ | local-http-mcp |
| idapro | ✗ | ✗ | — | — | — | ✓ | local-http-mcp |
| r2 | ✗ | ✗ | — | — | — | ✓ | github-release-zip |
| rabin2 | ✗ | ✗ | — | — | — | ✓ | github-release-zip |
| adb | ✗ | ✗ | — | — | — | ✓ | winget-package |
| agent-browser | ✗ | ✗ | — | — | — | ✓ | npm-global |
| ghidra-mcp | ✗ | ✗ | — | — | — | ✓ | github-release-zip |
| seclists | ✗ | ✗ | — | — | — | ✓ | git-clone |
| proxycat | ✗ | ✗ | — | — | — | ✓ | git-clone |
| burpsuite-mcp | ✗ | ✗ | — | — | — | ✗ | local-http-mcp |
| pentestswarm | ✗ | ✗ | — | — | — | ✓ | go-install |
| nmap | ✗ | ✗ | — | — | — | ✓ | winget-package |
| binwalk | ✗ | ✗ | — | — | — | ✓ | winget-package |
| yara | ✗ | ✗ | — | — | — | ✓ | winget-package |
| pwntools | ✗ | ✗ | — | — | — | ✓ | pip-package |
| bkcrack | ✗ | ✗ | — | — | — | ✓ | github-release-zip |

> ✓ = 是 | ✗ = 否 | — = 不适用或未检测

