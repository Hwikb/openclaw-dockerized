# 🚀 OpenClaw-Dockerized

## 📖 项目简介

**OpenClaw** 是一个强大且高度可扩展的 AI Agent 框架，能够连接大语言模型与各种外部工具、平台（如飞书、Slack 等），实现自动化任务处理与对话交互。

本项目旨在通过 **Docker** 容器化技术，为你提供一个开箱即用的 OpenClaw 部署方案。通过分离构建环境与运行环境、独立配置 CLI 服务，本项目不仅解决了环境依赖带来的痛点，还让后续的版本迭代、代理配置以及平台接入（如飞书）变得异常简单和清晰。

---

## 🛠️ 第一步：环境准备与镜像配置

你可以根据自己的需求，选择直接拉取已编译好的镜像，或者在本地自行构建。

### 选项 A：拉取预构建镜像 (推荐)
如果你想快速启动，可以直接使用已经打包好的 Docker 镜像。修改你的 `docker-compose.yml`，将 image 指定为：
```yaml
image: hwikby/openclaw-ob:v1
```

### 选项 B：本地自行构建
如果你需要深度定制，或者想使用最新版本的 OpenClaw，可以通过以下命令自行构建：
```bash
docker compose up -d --build
```

### ⚙️ 核心 `.env` 参数说明
在启动之前，请确保你已经配置好了 `.env` 文件。以下是几个至关重要的环境变量：

* `OPENCLAW_VERSION`: 指定你需要安装的 OpenClaw 版本（如 `latest` 或具体版本号）。
* `OPENCLAW_CONFIG_DIR`: 宿主机上存储 OpenClaw 配置文件的路径（建议设置为 `./data` 或 `./config`），确保数据持久化。
* `BUILD_HTTP_PROXY`: **构建时代理**。仅在 `docker build` 阶段拉取 npm 依赖时使用，防止网络问题导致构建失败。
* `OPENCLAW_RUNTIME_HTTP_PROXY`: **运行时代理**。用于 OpenClaw 启动后，请求外部 API 时的网络代理。

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

---

## 🧠 第三步：配置模型 API

完成初始化后，你需要为 OpenClaw 配置底层的大语言模型。使用 CLI 服务进行安全配置：

```bash
# 以 OpenAI 为例，设置你的 API Key
docker compose run --rm openclaw-cli config set providers.openai.apiKey "sk-你的API密钥"

# 如果你使用的是中转代理地址，可以设置 baseURL
docker compose run --rm openclaw-cli config set providers.openai.baseURL "https://你的代理地址/v1"

# 设置默认使用的模型
docker compose run --rm openclaw-cli config set defaultModel "gpt-4o"
```
*配置完成后，记得重启主服务（`docker compose restart openclaw`）以使其生效。*

---

## 🔗 第四步：Gateway 与设备配对

OpenClaw 默认启用了安全网关机制。如果在浏览器直接访问 `localhost:18789`，可能会遇到以下两种常见拦截：

### 错误 1: `unauthorized: gateway token mismatch`
这是因为访问需要携带安全 Token。请在终端执行以下命令，获取包含 Token 的专属免密链接：

```bash
docker compose run --rm openclaw-cli dashboard --no-open
```

终端会输出一个类似如下的链接：
> `http://localhost:18789/chat?session=main&token=xxxxxx`

直接复制该链接到浏览器中打开即可。
💡 **Tip:** 如果之后忘记了 token，可以进入配置挂载目录（如 `./data`），找到 `openclaw.json` 文件，在 `gateway` 节点下即可找到对应的 token 参数。

### 错误 2: `pairing required`
说明当前的浏览器设备尚未被网关信任。请按以下步骤进行设备配对：

1.  **查看待处理请求**：
    在终端执行以下命令，找到 `Pending` 状态的请求，并记录下 `<request ID>`。
    ```bash
    docker compose exec openclaw-gateway openclaw devices list
    ```

2.  **批准请求**：
    将获取到的 ID 替换到下方命令中并执行：
    ```bash
    docker compose exec openclaw-gateway openclaw devices approve --latest
    ```

---

## 💬 第五步：接入聊天软件 (飞书)

将 OpenClaw 接入飞书分为“飞书后台配置”与“OpenClaw 容器配置”两部分。

### 5.1 飞书开放平台准备工作
1. **创建应用**：登录飞书开发者后台，点击“创建企业自建应用”。
2. **获取凭证**：进入应用详情，在“凭证与基础信息”中，记录下你的 `App ID` (以 `cli_` 开头) 和 `App Secret`。
3. **添加机器人**：在左侧导航栏选择“添加应用能力”，添加“机器人”功能。
4. **配置权限**：在“权限管理”中，申请机器人必备权限（如“接收消息”、“发送消息”等），并在右上角点击“创建版本”并发布。
5. **事件与回调 (Webhook)**：在“事件订阅”中配置服务器的回调地址（指向你服务器公网 IP/域名 及 OpenClaw 对应监听的 Webhook 路径），并添加需要订阅的事件（如 `接收消息 v2.0`）。

### 5.2 OpenClaw 注入飞书配置
得益于我们的容器化架构，无需修改任何代码，直接通过 CLI 将你在上一步获取的凭证注入到配置中：

```bash
# 1. 开启飞书渠道支持
docker compose run --rm openclaw-cli config set channels.feishu.enabled true

# 2. 设置飞书 App ID (替换为你实际的 App ID)
docker compose run --rm openclaw-cli config set channels.feishu.appId "cli_xxxxx"

# 3. 设置飞书 App Secret (替换为你实际的 App Secret)
docker compose run --rm openclaw-cli config set channels.feishu.appSecret "your_app_secret"

# 4. 重启主服务，让配置正式生效并启动监听
docker compose restart openclaw
```

---

## 🐳 第六步：Docker 常用运维指令

日常维护和调试时，这些命令会非常有用：

* **后台启动所有服务**
  ```bash
  docker compose up -d
  ```
* **停止并移除容器** (不会删除挂载的数据持久化卷)
  ```bash
  docker compose down
  ```
* **查看主服务实时日志** (排查网络、飞书回调报错必备)
  ```bash
  docker compose logs -f openclaw
  ```
* **重启主服务** (修改任何配置后都必须执行)
  ```bash
  docker compose restart openclaw
  ```
* **进入主容器内部** (用于深度调试或测试容器内网络连通性)
  ```bash
  docker exec -it openclaw-server /bin/sh
  ```
