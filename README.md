# 🚀 OpenClaw-Dockerized

## 📖 项目简介

**OpenClaw** 是一款功能极其强大的企业级 AI Agent 核心框架。它不仅具备极高的可扩展性，更能将顶尖的大型语言模型（LLMs）与各种复杂的外部工具、API 以及主流协作平台（如飞书、Slack 等）无缝连接，从而打造出能够自主感知、规划并执行复杂自动化任务的超级智能体。

本项目旨在通过 **Docker** 容器化技术，为你提供一个最优雅、开箱即用的 OpenClaw 部署方案。本项目的核心特色包括：

* 📦 **环境隔离与极简部署**：通过分离构建环境与运行环境，彻底解决本地依赖冲突和跨平台运行的痛点。
* 🔄 **平滑的版本迭代**：借助独立的 CLI 服务与精简的 `Dockerfile` 设计，只需调整配置参数即可轻松完成版本升级。
* 🌐 **灵活的代理控制**：在 `.env` 中严格区分构建时（Build-time）与运行时（Runtime）的网络代理，轻松应对各种复杂的网络限制。
* 🔌 **无痛接入协作平台**：提供极其清晰的步骤，教你通过动态指令将 OpenClaw 快速、稳定地接入**飞书**等企业级应用。
* 🛠️ **进阶 Skills (技能) 配置指导**：除了基础搭建，本项目还将详细演示如何为你的 Agent 扩展和配置强大的 **Skills**，让模型如虎添翼，真正具备实战落地能力。

---

## 🛠️ 第一步：环境准备与镜像配置

在获取镜像之前，我们需要先准备好基础的环境变量配置文件。

### ⚙️ 核心 `.env` 参数说明
请确保你已经在项目目录中配置好了 `.env` 文件。以下是几个至关重要的环境变量：

* `OPENCLAW_VERSION`: 指定你需要安装的 OpenClaw 版本（如 `latest` 或具体版本号）。
* `OPENCLAW_CONFIG_DIR`: 宿主机上存储 OpenClaw 配置文件的路径（建议设置为 `./data` 或 `./config`），确保数据持久化。
* `BUILD_HTTP_PROXY`: **构建时代理**。仅在 `docker build` 阶段拉取 npm 依赖时使用，防止网络问题导致构建失败。
* `OPENCLAW_RUNTIME_HTTP_PROXY`: **运行时代理**。用于 OpenClaw 启动后，请求外部 API 时的网络代理。

### 🐳 获取镜像

配置好环境变量后，你可以根据自己的需求，选择直接拉取已编译好的镜像，或者在本地自行构建名为 `openclaw-dockerized` 的镜像。

#### 选项 A：拉取预构建镜像 (推荐)
如果你想快速启动，可以直接在终端使用 `docker pull` 命令拉取已经打包好的 Docker 镜像：
```bash
docker pull hwikby/openclaw-dockerized:v1
```

#### 选项 B：本地自行构建
如果你需要深度定制，或者想配合你的代理参数构建最新版本的 OpenClaw，可以在包含 `Dockerfile` 的目录下，通过 `docker build -t` 命令自行构建镜像：
```bash
docker build -t openclaw-dockerized -f Dockerfile .
```

---

## 🚀 第二步：初始化配置

在完成容器启动后，需要对 OpenClaw 进行初始向导配置。我们在终端中通过专门的 `openclaw-cli` 容器来执行：

```bash
docker compose run --rm openclaw-cli onboard
```

接下来终端会出现交互式选项，请严格按如下指引操作：

| 步骤提示 (Prompt) | 操作/输入 (Action) |
| :--- | :--- |
| **I understand this is powerful and inherently risky. Continue?** | 输入 **Yes** |
| **Onboarding mode** | 选择 **QuickStart** |
| **model/auth provider** | 选择 **Skip for now** |
| **Filter models by provider** | 选择 **All providers** |
| **Default model** | 选择 **Keep current** |
| **Select channel** | 选择 **Skip for now** |
| **Configure skills now?** | 选择 **No** |
| **Enable hooks?** | 移动光标到 **Skip for now**，按 **空格键** 选中，然后按 **回车 (Enter)** |

💡 **提示：** 以上交互指引旨在帮你完成 OpenClaw 的**最小化基础配置**，以确保核心服务能最快跑通。至于具体的底层大模型接入、平台插件以及强大的 Skills (技能) 配置，我们将会在后续的步骤中详细展开。

---

## 🧠 第三步：openclaw.json 文件配置

完成初始向导后，OpenClaw 的核心配置文件 `openclaw.json` 会生成在你挂载的配置目录中（例如 `./data/openclaw.json` ）。接下来我们可以手动编辑这个文件，完成网关、模型和 Agent 的进阶配置。

### 3.1 Gateway (网关) 配置

找到并修改 `gateway` 节点，这段配置决定了你如何访问 OpenClaw 的控制台界面以及访问权限：

```json
"gateway": {
  "port": 18789,
  "mode": "local",
  "bind": "lan",
  "auth": {
    "mode": "token",
    "token": "your log in token"
  },
  "controlUi": {
    "dangerouslyAllowHostHeaderOriginFallback": true
  },
  "tailscale": {
    "mode": "off",
    "resetOnExit": false
  }
}
```

**🔑 核心参数说明：**
* `port`: 控制台 UI 的访问端口，默认为 `18789`，需与 `docker-compose.yml` 中映射的端口对应。
* `bind`: 绑定网络接口。设置为 `"lan"` 允许局域网或公网访问（如果在云服务器部署，通常需要设置为 lan 以便外部访问）。
* `auth.token`: 你的访问密钥。请自定义一串高强度密码并填入此处。后续在浏览器访问 UI 时，需要在 URL 中携带此 token 才能成功认证（如 `?token=your log in token`）。
* `controlUi.dangerouslyAllowHostHeaderOriginFallback`: 强烈建议设置为 `true`。这可以防止在使用 Nginx 反向代理、内网穿透或 Docker 环境转发时，因请求头不匹配导致控制台出现白屏或被拒绝访问。

### 3.2 Models (大模型) 配置

找到 `models` 节点，配置你希望接入的 LLM 提供商。这里以配置 **DeepSeek** 为例：

```json
"models": {
  "providers": {
    "deepseek":{
      "baseUrl": "[https://api.deepseek.com/v1](https://api.deepseek.com/v1)",
      "apiKey": "your-api-key",
      "api":"openai-completions",
      "models":[
        {
          "id": "deepseek-chat",
          "name": "DeepSeek V3"
        },
        {
          "id": "deepseek-reasoner",
          "name": "DeepSeek R1"
        }
      ]
    }
  }
}
```

**🔑 核心参数说明：**
* `baseUrl`: API 的基础调用地址。
* `apiKey`: 你在模型供应商处申请的 API 密钥，请务必替换为你自己的真实 key。
* `api`: 接口格式规范。DeepSeek 完全兼容 OpenAI 的接口规范，因此这里填写 `"openai-completions"` 即可。
* `models`: 注册具体可用的模型列表。
  * `id`: 模型实际调用时的标识符，供系统内部识别。
  * `name`: 在 OpenClaw 控制台 UI 界面展示的易读名称。

### 3.3 Agents (智能体) 配置

最后，找到 `agents` 节点，配置 Agent 的默认行为和工作区路径：

```json
"agents": {
  "defaults": {
    "workspace": "/home/node/.openclaw/workspace",
    "compaction": {
      "mode": "safeguard"
    },
    "model": { 
      "primary": "deepseek/deepseek-chat"
    },
    "maxConcurrent": 4,
    "subagents": {
      "maxConcurrent": 8
    }
  }
}
```

**🔑 核心参数说明：**
* `workspace`: Agent 在容器内的默认工作目录路径。请确保此路径与你在 `docker-compose.yml` 中设置的内部挂载路径完全一致。
* `model.primary`: Agent 默认使用的主力大模型。格式必须是 `提供商名称/模型ID`。这里的 `"deepseek/deepseek-chat"` 正好对应了上一步我们在 `models` 中定义的提供商 (`deepseek`) 和具体的模型 ID (`deepseek-chat`)。
* `maxConcurrent` / `subagents.maxConcurrent`: 控制主 Agent 和子 Agent 并发执行任务的最大数量。你可以根据主机服务器的 CPU 和内存性能进行适当微调。

> ⚠️ **重要提示**：修改完 `openclaw.json` 保存后，请务必在终端执行 `docker compose restart openclaw` 重启主服务，让所有新的配置正式生效！

---

## 🔗 第四步：Gateway 与设备配对

OpenClaw 默认启用了安全网关机制。如果在浏览器直接访问 `localhost:18789`，可能会遇到以下两种常见拦截：

### 错误 1: `unauthorized: gateway token mismatch`
这是因为访问需要携带安全 Token。

**解决方法**：打开你挂载的配置文件 `openclaw.json`，找到 `gateway` 节点下配置的 `token` 值（即你在第三步中设置的自定义密钥）。然后在浏览器地址栏拼接该 token 进行访问即可：
> `http://localhost:18789/chat?token=你的token`

### 错误 2: `pairing required`
说明当前的浏览器设备尚未被网关信任。请按以下步骤进行设备配对：

1.  **查看待处理请求**：
    在终端执行以下命令，找到 `Pending` 状态的请求，并记录下 `<request ID>`。
    ```bash
    docker compose exec openclaw-gateway openclaw devices list
    ```

2.  **批准请求**：
    执行以下命令直接批准最新的设备配对请求（或者将 `--latest` 替换为上一步记录的具体 `<request ID>`）：
    ```bash
    docker compose exec openclaw-gateway openclaw devices approve --latest
    ```

---

## 💬 第五步：接入聊天软件 (飞书)

将 OpenClaw 接入飞书分为“飞书后台准备”、“OpenClaw 容器配置”和“建立长连接并发布”三个阶段。
**强烈建议使用长连接（WebSocket）模式**，这样无需配置公网 IP 或内网穿透即可穿透到本地 Docker 环境。

### 5.1 飞书开放平台准备工作 (第一阶段)

1. **创建应用**：登录 [飞书开发者后台](https://open.feishu.cn/app/)，点击“创建企业自建应用”。
2. **添加机器人能力**：在左侧导航栏选择“添加应用能力”，在列表中添加“机器人”。
3. **获取凭证 (重要)**：进入“凭证与基础信息”，记录下你的 `App ID` (以 `cli_` 开头) 和 `App Secret`，马上就要在 Docker 中用到。
4. **开通核心权限**：在“权限管理”中，搜索并**务必开通**以下权限，否则机器人将无法正常收发消息或解析用户信息：
   * `im:message` (获取与发送单聊、群组消息)
   * `im:message.p2p_msg:readonly` (读取用户发给机器人的单聊消息)
   * `im:message.group_at_msg:readonly` (获取群组中所有消息 或 接收被@的消息)
   * `im:message:send_as_bot` (以应用的身份发消息)
   * `im:resource` (获取与上传图片或文件资源)
   * **`contact:contact.base:readonly` (获取用户基本信息 - 极易漏掉，用于识别发信人)**

*(注意：先不要去“事件与回调”页面配置长连接，因为必须等 Docker 启动并主动发起连接后，飞书才能检测通过。)*

### 5.2 OpenClaw 注入飞书配置 (第二阶段)

得益于容器化架构，我们只需通过 CLI 安装插件并注入你在上一步获取的凭证：

```bash
# 1. 安装飞书通道插件
docker compose run --rm openclaw-cli plugins install @overlink/openclaw-feishu

# 2. 设置飞书 App ID (替换为你实际的 App ID)
docker compose run --rm openclaw-cli config set channels.feishu.appId "cli_xxxxx"

# 3. 设置飞书 App Secret (替换为你实际的 App Secret)
docker compose run --rm openclaw-cli config set channels.feishu.appSecret "your_app_secret"

# 4. 开启飞书渠道支持 (总开关)
docker compose run --rm openclaw-cli config set channels.feishu.enabled true

# 5. 重启网关服务，强制建立 WebSocket 长连接 (关键！)
docker compose restart openclaw-gateway
```

> **💡 避坑指南：**
> 重启 `openclaw-gateway` 后，OpenClaw 会在后台主动拿着配置好的凭证去敲飞书服务器的门，建立起 WebSocket 通道。只有这一步跑通了，下一步在飞书后台的配置才不会报错。

### 5.3 开启事件订阅与发布上线 (第三阶段)

确认 Docker 端的网关已经重启完毕后，回到飞书开发者后台完成最后收尾：

1. **配置事件长连接**：在左侧导航栏进入“事件与回调”。订阅方式选择 **“使用长连接 (Receive events through persistent connection)”**。此时由于 Docker 已在后台连通，飞书将顺利通过检测。
2. **添加订阅事件**：在下方点击“添加事件”，勾选 **`接收消息 (im.message.receive_v1)`**。
3. **创建版本并发布**：进入左侧的“版本管理与发布”，点击“创建版本”（如 `1.0.0`），点击保存并申请发布。

发布通过后，即可在飞书客户端搜索该机器人应用，享受完全私有化的 AI 对话体验！

---

## 🛠️ 第六步：进阶 Skills (技能) 安装配置

本文档记录了在 Docker 环境下，为 OpenClaw 安装和配置插件的快捷指令。

### 🌐 技能从哪来？认识 ClawHub
**ClawHub** 是 OpenClaw 的技能与插件生态中心，相当于 Agent 的“应用商店”。
在执行任何安装命令之前，你都可以前往 ClawHub 社区或官方平台，浏览并搜索你需要的扩展能力（例如代码管理、数据分析、联网搜索等）。找到心仪的技能后，记下它的名称（slug），就可以使用下方的命令进行安装了。

### 🚀 核心操作：在容器内安装 Skills

由于 OpenClaw 运行在 Docker 隔离环境中，我们需要通过 `docker compose exec` 直接向服务发送安装命令。在包含 `docker-compose.yml` 的目录下，运行以下命令依次安装需要的核心技能：

```bash
# 1. 安装技能安全扫描工具（养成安全好习惯，强烈建议安装其他技能前先扫描）
docker compose exec openclaw-gateway npx clawhub@latest install skill-vetter

# 2. 安装 Tavily 联网搜索技能
docker compose exec openclaw-gateway npx clawhub@latest install tavily-search

# 3. 安装自我进化技能（提升 Agent 反思与自我纠错能力）
docker compose exec openclaw-gateway npx clawhub@latest install self-improving-agent

# 4. 安装主动提议技能（赋予 Agent 主动打断和提出优化的能力）
docker compose exec openclaw-gateway npx clawhub@latest install proactive-agent
```

### ⚠️ 补充说明：环境变量与 API Key 配置

部分依赖外部云服务的插件（例如 `tavily-search`）在安装完成后，**必须在 Docker 环境中配置相应的 API_KEY 才能正常工作**。

你需要通过修改项目根目录的 `.env` 文件以及 `docker-compose.yml` 的 `environment` 节点，将相关的密钥（如 `TAVILY_API_KEY`）作为环境变量注入到容器底层。最后执行以下命令重启容器即可生效：

```bash
docker compose down
docker compose up -d
```

---

## 🐳 第七步：Docker 常用运维指令

日常维护、排查报错和更新升级时，以下命令表格会非常有用：

| 运维场景 / 作用说明 | Docker / Compose 指令 |
| :--- | :--- |
| **查看运行状态** (排查服务是否存活及端口映射) | `docker ps` <br> *(或 `docker compose ps`)* |
| **启动服务** (在后台启动所有容器) | `docker compose up -d` |
| **停止服务** (停止并移除容器，不会删除挂载数据) | `docker compose down` |
| **查看主服务日志** (排查网络、飞书回调、模型报错等) | `docker compose logs -f openclaw` |
| **查看网关日志** (排查控制台访问被拒、设备配对失败) | `docker compose logs -f openclaw-gateway` |
| **重启主服务** (修改 `openclaw.json` 等配置后必须执行) | `docker compose restart openclaw` |
| **重新构建启动** (修改 `Dockerfile` 或更新基础镜像后执行) | `docker compose up -d --build` |
| **进入容器内部** (用于深度调试或测试容器内网络连通性) | `docker exec -it openclaw-server /bin/sh` |


## 🔗 参考资料

1. [OpenClaw 官方 Docker 文档](https://docs.openclaw.ai/install/docker)
2. [ClawHub 官网 (插件/技能中心)](https://clawhub.ai/)
3. [OpenClaw 配置说明 (Gateway Configuration)](https://docs.openclaw.ai/gateway/configuration)
---

## 📄 许可证 (License)

本项目基于 **MIT License** 开源。你可以自由地使用、修改和分发本项目，但请保留原始的版权声明。详情请参阅项目中的 [LICENSE](LICENSE) 文件。
