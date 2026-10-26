# reverse-skill 技能导航索引

> 本文件由 `skills/scripts/extract-summaries.ps1` 自动生成，**请勿手改**。
> 修改摘要请编辑对应模块 `SKILL.md` 的 frontmatter `description`，然后重跑脚本。

## 模块总览

| 模块 | 摘要 |
|------|------|
| [api-security](api-security/SKILL.md) | Use for authorized security assessment of REST, GraphQL, WebSocket, or SOAP APIs, including discovery, authentication, authorization, rate-limit, and CI/CD t... |
| [apk-reverse](apk-reverse/SKILL.md) | 在 CLI 环境下做 Android APK 逆向时使用。适用于 APK 解包、Java 反编译、smali 修改、重打包、Frida 动态 Hook，以及按需切换到 so/native 分析。优先使用本机已安装的 jadx、apktool、frida、adb、ida-reverse、radare2。 |
| [attack-chain](attack-chain/SKILL.md) | Use for authorized multi-stage attack-path planning and orchestration when a task spans reconnaissance, initial access, privilege escalation, lateral movemen... |
| [audit-onboarding-proposal](audit-onboarding-proposal/SKILL.md) | Independently audit a brownfield onboarding transcript, operational map, or exact proposed documentation patch before application. Use when a fresh reviewer ... |
| [binary-diff](binary-diff/SKILL.md) | 跨版本符号迁移与二进制差分。当你有旧版本的符号/逆向结果，需要快速迁移到新版本时使用。 |
| [brainstorming](brainstorming/SKILL.md) | Interactive exploration, user intent elicitation, and design tradeoff discovery before code generation. Use when requirements are open-ended or ambiguous. |
| [browser-automation](browser-automation/SKILL.md) | 统一自动化入口。覆盖浏览器自动化（Playwright）和 Windows 桌面应用自动化（OpenReverse）。 |
| [browser-extension-reverse](browser-extension-reverse/SKILL.md) | Use for authorized reverse engineering of browser extensions (Chrome/Firefox) including manifest analysis, background workers, and extension-based credential... |
| [case-review](case-review/SKILL.md) | Reviews a reverse-skill case package for scope readiness, Evidence to Finding to Path traceability, work item coverage, timeline references, and optional art... |
| [caveman](caveman/SKILL.md) | Terse, high-signal developer communication mode. Why many token when few do trick. Answer first, drop filler, preserve technical accuracy, save 30-50% tokens. |
| [cloud-k8s](cloud-k8s/SKILL.md) | Use for authorized cloud, container, and Kubernetes security assessment including metadata SSRF, IAM misconfig, container escape paths, and cluster RBAC review. |
| [code-audit](code-audit/SKILL.md) | Use for authorized source-code security review and SAST workflows including Semgrep, CodeQL patterns, dangerous API hunting, and fix verification. |
| [code-review](code-review/SKILL.md) | Comprehensive multi-stage code review assessing behavioral correctness, architectural invariants, security, and performance. |
| [database-migrations-design](database-migrations-design/SKILL.md) | Production database design, indexing strategy, zero-downtime schema migrations (Expand-Contract pattern), and ORM query optimization (Prisma, Drizzle, SQLAlc... |
| [database-security](database-security/SKILL.md) | Use for authorized database security assessment covering PostgreSQL/MySQL/MSSQL/Mongo/Redis exposure, authz, UDF/command paths, and misconfiguration review. |
| [design-taste](design-taste/SKILL.md) | Design Taste guidelines for visual hierarchy, depth layers, glassmorphism, sophisticated contrast, and premium aesthetic execution. |
| [diagram-generator](diagram-generator/SKILL.md) | generate, refine, validate, and render diagrams from natural language, notes, code snippets, schemas, tables, or existing diagram source. use for flowcharts,... |
| [digital-forensics](digital-forensics/SKILL.md) | Use for authorized digital forensics including memory dumps, disk timelines, PCAP investigation, artifact triage, and IR evidence preservation. |
| [docker-devops-ci](docker-devops-ci/SKILL.md) | Production Docker, Docker Compose, container security, multi-stage builds, and GitHub Actions CI/CD automation. |
| [docs-generator](docs-generator/SKILL.md) | Creates task-oriented technical documentation with progressive disclosure. Use when writing READMEs, API docs, architecture docs, or markdown documentation. |
| [dotnet-reverse](dotnet-reverse/SKILL.md) | .NET / C# 二进制逆向。当目标是 .NET assembly（PE 头含 CLR、.exe/.dll 托管程序）、C# 编译产物（含 NativeAOT）、红队 Sharp* 工具（Rubeus / SharpHound / SharpHound 等）、.NET 混淆程序（ConfuserEx / Sma... |
| [ecc-architecture](ecc-architecture/SKILL.md) | ECC architectural design and invariant enforcement. Manages domain boundaries, state machines, event dispatching, and system resilience. |
| [ecc-performance](ecc-performance/SKILL.md) | ECC high-performance engineering. Hot-path optimization, database query profiling, memory leak detection, and cache orchestration. |
| [ecc-refactoring](ecc-refactoring/SKILL.md) | ECC safe refactoring workflow. Preserves behavioral contracts, extracts reusable abstractions, and eliminates technical debt. |
| [ecc-security-guard](ecc-security-guard/SKILL.md) | ECC security guardrails. Enforces OWASP Top 10 defenses, tenant isolation, input sanitation, and secret protection. |
| [edr-bypass-re](edr-bypass-re/SKILL.md) | 逆向防御方实现 → 红队针对性绕过。把 EDR / Defender / AV 的 hook 表、ETW provider、AMSI 实现先逆向出来， |
| [email-security](email-security/SKILL.md) | Use for authorized email security review including phishing analysis, header authentication (SPF/DKIM/DMARC), BEC patterns, and mailbox token abuse research. |
| [empirical-evidence-guard](empirical-evidence-guard/SKILL.md) | Enforces ground-truth empirical metrics, prevents hallucinated terminal logs, bans hollow/tautological tests, and mandates real tool-driven security audits. |
| [encode-invariant](encode-invariant/SKILL.md) | Convert accepted repository rules into the smallest repository-native mechanical validation with positive and negative proof and precise enforcement-level re... |
| [engineering-wisdom](engineering-wisdom/SKILL.md) | Provide an explicitly requested, repository-grounded engineering review using contextual heuristics for code clarity, SOLID and design, testing, refactoring,... |
| [firmware-pentest](firmware-pentest/SKILL.md) | 固件 / IoT 渗透链。从拿到一坨 .bin / .img 开始，闭环走完逆向 → 提取 → 模拟 → 利用。 |
| [forgewright](forgewright/SKILL.md) | Adaptive AI Engineering Orchestrator managing the 5 lifecycle stages (Define, Build, Harden, Ship, Sustain), multi-agent orchestration, and autonomous qualit... |
| [ghidra-reverse](ghidra-reverse/SKILL.md) | Use for free/open reverse engineering with Ghidra (headless or GUI), including decompile, cross-refs, and optional Ghidra MCP workflows when IDA is unavailable. |
| [go-engineering](go-engineering/SKILL.md) | Production Go (Golang) engineering standard covering standard project layout, table-driven tests, goroutine & channel safety, context propagation, and error ... |
| [go-rust-reverse](go-rust-reverse/SKILL.md) | Use for reverse engineering stripped Go and Rust binaries including runtime recognition, pclntab/moduel data recovery, panic strings, and idiomatic decompila... |
| [hardware-security](hardware-security/SKILL.md) | Use for authorized hardware and embedded interface security research including UART/JTAG discovery, debug pad triage, secure boot overview, and offline firmw... |
| [ida-reverse](ida-reverse/SKILL.md) | IDA Pro 逆向分析辅助技能。当用户提到逆向、反编译、分析二进制/PE/ELF/APK/DLL/SO、破解、找密码、漏洞分析、病毒分析、firmware 固件分析，或需要分析 exe/dll/so/elf/macho/sys 等文件时，务必使用此技能。 |
| [identity-federation](identity-federation/SKILL.md) | Use for authorized assessment of federated identity systems including SAML, OIDC, OAuth2 flows, SSO misconfiguration, and token confusion issues. |
| [impeccable-design](impeccable-design/SKILL.md) | Impeccable frontend craft and anti-AI-slop design system. Enforces intentional visual aesthetics, micro-interactions, layout rhythms, and bespoke styling. |
| [improve-harness](improve-harness/SKILL.md) | Run one explicitly authorized, evidence-backed improvement to a repository's agent guidance, tools, runbooks, or validation. Use only when the user invokes `... |
| [js-reverse](js-reverse/SKILL.md) | 在使用 js-reverse-mcp 做前端 JavaScript 逆向时使用，适用于签名链路定位、页面观察取证、运行时采样、本地补环境复现与证据化输出。优先适配当前环境里的 js-reverse_* 工具，需要更强的浏览器/CDP/Hook 面时联动 jshookmcp。 |
| [llm-security](llm-security/SKILL.md) | Use for authorized security assessment of LLM applications and AI agents, including prompt injection, tool abuse, RAG exposure, memory poisoning, and model s... |
| [macos-reverse](macos-reverse/SKILL.md) | Use for authorized macOS and Mach-O reverse engineering including codesign, Objective-C/Swift recovery, endpoint security surfaces, and Apple platform malwar... |
| [malware-analysis](malware-analysis/SKILL.md) | Use when analyzing suspected malware through static, dynamic, and behavioral techniques, including IOC extraction, YARA or Sigma rules, sandboxing, and anti-... |
| [mobile-reverse](mobile-reverse/SKILL.md) | Use for authorized Android or iOS application reverse engineering and security testing, including APK or IPA analysis, runtime instrumentation, SSL pinning, ... |
| [onboard-repository](onboard-repository/SKILL.md) | Inspect an unfamiliar or brownfield repository, trace one real operational path, and propose evidence-backed improvements that help future agents work indepe... |
| [ot-ics](ot-ics/SKILL.md) | Use for authorized OT/ICS security assessment covering Purdue model zoning, PLC/SCADA exposure, industrial protocol discovery, and safe passive-first evaluat... |
| [patch-diff-exploit](patch-diff-exploit/SKILL.md) | N-day 补丁差分到利用。从厂商发布的补丁里反推漏洞点、写 PoC、做成可用的攻击模块。 |
| [pentest-tools](pentest-tools/SKILL.md) | 主动渗透测试工具链。覆盖信息收集、端口扫描、漏洞扫描、Web 渗透、SQL 注入、目录爆破、密码破解等场景。 |
| [src-hunter](pentest-tools/src-hunter/SKILL.md) | 实战 SRC / 众测 / Bug bounty 漏洞挖掘工作流 skill。包含：5 阶段方法论（intake → recon → enum → hunt → report）、19 个攻击类 playbook（SQLi/XSS/RCE/SSRF/IDOR/CSRF/Path Traversal/File Upl... |
| [ponytail](ponytail/SKILL.md) | Channel a lazy senior developer. Fight overengineering. Implement the simplest thing that could possibly work. Keep existing patterns. Fix root causes, not s... |
| [protocol-reverse](protocol-reverse/SKILL.md) | Use for authorized reverse engineering of custom binary protocols, Protobuf/gRPC, WebSocket frames, and PCAP-driven protocol recovery. |
| [pwn-chain](pwn-chain/SKILL.md) | 从逆向走到可用利用 (Working Exploit) 的全链路工程化方法。 |
| [python-engineering](python-engineering/SKILL.md) | Production-grade Python engineering best practices covering FastAPI, Django, Pytest TDD, Type Annotations, Pydantic v2, Ruff, and async patterns. |
| [radare2](radare2/SKILL.md) | Use this skill whenever the user wants to analyze binaries with radare2/r2 from the command line, including reverse engineering, disassembly, function analys... |
| [radio-sdr](radio-sdr/SKILL.md) | Use for authorized RF/SDR security research including signal identification, replay feasibility study in shielded labs, and wireless protocol analysis outsid... |
| [dsl-vm-reverse](reverse-engineering/dsl-vm-reverse/SKILL.md) | Reverse JavaScript-based custom DSL/VM interpreters, non-standard WASM-like runtimes, and risk-control engines. Use when analyzing IIFE or switch-based opcod... |
| [reverse-engineering](reverse-engineering/SKILL.md) | Provides reverse engineering techniques. Use when the main job is to understand how a compiled, obfuscated, packed, or virtualized target works before exploi... |
| [reverse-skill-router](reverse-skill-router/SKILL.md) | Routes reverse engineering, exploitation, penetration testing, malware, mobile, firmware, browser automation, documentation, and security tasks to the approp... |
| [rust-engineering](rust-engineering/SKILL.md) | Production Rust guidelines covering ownership, lifetimes, Result/Option error handling, async Tokio, zero-cost abstractions, and Clippy invariants. |
| [subagent-driven-development](subagent-driven-development/SKILL.md) | Fast 2-5 minute task delegation, context isolation, verifiable task contracts, and deterministic subagent handoffs. |
| [supply-chain-security](supply-chain-security/SKILL.md) | Use for software supply-chain security assessment covering SBOM, SCA, CI/CD pipelines, container images, build integrity, dependency provenance, and vulnerab... |
| [systematic-debugging](systematic-debugging/SKILL.md) | Root-cause isolation, hypothesis testing, binary search, non-destructive diagnosis, and anti-guesswork debugging. |
| [test-driven-development](test-driven-development/SKILL.md) | Strict Red-Green-Refactor test-driven development workflow. Write failing unit/integration tests before implementing code. |
| [thick-client](thick-client/SKILL.md) | Use for authorized security testing of desktop thick clients including local storage, update channels, IPC, traffic, and client-side trust boundaries. |
| [threat-hunting](threat-hunting/SKILL.md) | Use for blue-team threat hunting, detection engineering with Sigma/YARA, SIEM query design, and incident detection validation. |
| [vercel-react-best-practices](vercel-react-best-practices/SKILL.md) | Vercel React & Next.js performance playbook. Enforces RSC boundaries, eliminating async waterfalls, bundle optimization, and Server Actions. |
| [verification-before-completion](verification-before-completion/SKILL.md) | Executable proof requirement, zero unverified assumptions, runtime validation, anti-hollow testing, and empirical evidence before claiming task completion. |
| [virtual-it-team](virtual-it-team/SKILL.md) | Orchestrates a virtual cross-functional IT department (Tech Lead, Senior Dev, QA Tester, AppSec Specialist, DevOps) for adversarial cross-checking, code revi... |
| [web-design-guidelines](web-design-guidelines/SKILL.md) | Modern web design standards covering mobile-first responsive layouts, fluid typography, dark/light accessibility, and SEO foundations. |
| [wifi-wireless](wifi-wireless/SKILL.md) | Use for authorized wireless security assessment including Wi-Fi capture, WPA handshake analysis, rogue AP detection research, and lab-only deauth testing. |
| [windows-ad](windows-ad/SKILL.md) | Use for authorized Active Directory and Windows identity attacks including Kerberos, AD CS, BloodHound paths, NTLM relay, and domain privilege escalation res... |
| [workflow-build-fix](workflow-build-fix/SKILL.md) | Global /build-fix workflow for diagnosing, isolating, and resolving compilation, TypeScript, bundling, and lint errors. |
| [workflow-code-review](workflow-code-review/SKILL.md) | Global /code-review workflow for automated static analysis, architecture validation, security audit, and quality assessment. |
| [workflow-feature-dev](workflow-feature-dev/SKILL.md) | Global /feature-dev end-to-end development workflow from spec and TDD to implementation and observable verification. |
| [workflow-plan](workflow-plan/SKILL.md) | Global /plan workflow for analyzing requirements, mapping dependencies, and generating structured technical execution plans. |
| [workflow-pr](workflow-pr/SKILL.md) | Global /pr workflow for generating semantic Git commits, comprehensive PR descriptions, and executable verification artifacts. |
| [workflow-quality-gate](workflow-quality-gate/SKILL.md) | Global /quality-gate workflow validating test passes, build status, invariant enforcement, and zero regressions before deployment or merge. |
| [writing-plans](writing-plans/SKILL.md) | Spec-first implementation planning, bite-sized tasks, dependency mapping, and observable verification criteria. |

## 目录树

```
skills/api-security/SKILL.md/
skills/apk-reverse/SKILL.md/
skills/attack-chain/SKILL.md/
skills/audit-onboarding-proposal/SKILL.md/
skills/binary-diff/SKILL.md/
skills/brainstorming/SKILL.md/
skills/browser-automation/SKILL.md/
skills/browser-extension-reverse/SKILL.md/
skills/case-review/SKILL.md/
skills/caveman/SKILL.md/
skills/cloud-k8s/SKILL.md/
skills/code-audit/SKILL.md/
skills/code-review/SKILL.md/
skills/database-migrations-design/SKILL.md/
skills/database-security/SKILL.md/
skills/design-taste/SKILL.md/
skills/diagram-generator/SKILL.md/
skills/digital-forensics/SKILL.md/
skills/docker-devops-ci/SKILL.md/
skills/docs-generator/SKILL.md/
skills/dotnet-reverse/SKILL.md/
skills/ecc-architecture/SKILL.md/
skills/ecc-performance/SKILL.md/
skills/ecc-refactoring/SKILL.md/
skills/ecc-security-guard/SKILL.md/
skills/edr-bypass-re/SKILL.md/
skills/email-security/SKILL.md/
skills/empirical-evidence-guard/SKILL.md/
skills/encode-invariant/SKILL.md/
skills/engineering-wisdom/SKILL.md/
skills/firmware-pentest/SKILL.md/
skills/forgewright/SKILL.md/
skills/ghidra-reverse/SKILL.md/
skills/go-engineering/SKILL.md/
skills/go-rust-reverse/SKILL.md/
skills/hardware-security/SKILL.md/
skills/ida-reverse/SKILL.md/
skills/identity-federation/SKILL.md/
skills/impeccable-design/SKILL.md/
skills/improve-harness/SKILL.md/
skills/js-reverse/SKILL.md/
skills/llm-security/SKILL.md/
skills/macos-reverse/SKILL.md/
skills/malware-analysis/SKILL.md/
skills/mobile-reverse/SKILL.md/
skills/onboard-repository/SKILL.md/
skills/ot-ics/SKILL.md/
skills/patch-diff-exploit/SKILL.md/
skills/pentest-tools/SKILL.md/
skills/pentest-tools/src-hunter/SKILL.md/
skills/ponytail/SKILL.md/
skills/protocol-reverse/SKILL.md/
skills/pwn-chain/SKILL.md/
skills/python-engineering/SKILL.md/
skills/radare2/SKILL.md/
skills/radio-sdr/SKILL.md/
skills/reverse-engineering/dsl-vm-reverse/SKILL.md/
skills/reverse-engineering/SKILL.md/
skills/reverse-skill-router/SKILL.md/
skills/rust-engineering/SKILL.md/
skills/subagent-driven-development/SKILL.md/
skills/supply-chain-security/SKILL.md/
skills/systematic-debugging/SKILL.md/
skills/test-driven-development/SKILL.md/
skills/thick-client/SKILL.md/
skills/threat-hunting/SKILL.md/
skills/vercel-react-best-practices/SKILL.md/
skills/verification-before-completion/SKILL.md/
skills/virtual-it-team/SKILL.md/
skills/web-design-guidelines/SKILL.md/
skills/wifi-wireless/SKILL.md/
skills/windows-ad/SKILL.md/
skills/workflow-build-fix/SKILL.md/
skills/workflow-code-review/SKILL.md/
skills/workflow-feature-dev/SKILL.md/
skills/workflow-plan/SKILL.md/
skills/workflow-pr/SKILL.md/
skills/workflow-quality-gate/SKILL.md/
skills/writing-plans/SKILL.md/
```

## 路由

PRIMARY 路由由 `skills/config/routing.json`（唯一事实源）驱动，用 `master-route.ps1 -Hint "<任务>"` 分诊。
歧义场景读 `skills/routing.md` 全矩阵；CTF 多类型任务走 `CTF-Sandbox-Orchestrator/`。
