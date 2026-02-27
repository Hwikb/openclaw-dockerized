# 使用官方 Node.js 镜像作为稳定底座
FROM node:22-bookworm

# ==========================================
# 构建参数区 (Build Arguments)
# ==========================================
# 满足要求 1：考虑版本迭代。用户可通过 --build-arg 覆盖
ARG OPENCLAW_VERSION=2026.2.24
# 考虑国内网络环境：仅在构建时接收代理，绝不污染运行环境
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG ALL_PROXY
ARG NO_PROXY

# ==========================================
# 构建执行区 (Build Execution)
# ==========================================
# 核心逻辑：利用 npm 动态拉取指定版本的预编译包，并强制清理无用缓存
RUN npm install -g openclaw@${OPENCLAW_VERSION} && \
    npm cache clean --force

# ==========================================
# 运行环境区 (Runtime Environment)
# ==========================================
ENV NODE_ENV=production

# 满足要求 4 的最佳实践：降权至非特权用户运行，保障云端部署安全
USER node

# 默认启动指令 (配置细节交由 docker-compose 外部接管)
CMD ["openclaw", "gateway", "--bind", "lan", "--port", "18789"]
