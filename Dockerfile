# ---- Stage 1: Download tool binaries ----
FROM debian:latest AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /stage

RUN curl -fsSL https://claude.ai/install.sh | bash \
    && cp /root/.local/bin/claude /stage/claude

RUN curl -fsSL https://chatgpt.com/codex/install.sh | CODEX_NON_INTERACTIVE=1 sh \
    && cp /root/.codex/packages/standalone/current/bin/codex /stage/codex

RUN curl -fsSL https://opencode.ai/install | bash \
    && cp /root/.opencode/bin/opencode /stage/opencode

# ---- Stage 2: Final image ----
FROM debian:trixie

SHELL ["/bin/bash", "-e", "-o", "pipefail", "-c"]

# ------------------------------------------------------------
# 基础构建与终端环境
# ------------------------------------------------------------
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai
ENV TERM=xterm-256color

# 时区、locale 和中文字体
RUN apt-get update && apt-get install -y --no-install-recommends \
    locales tzdata \
    fontconfig fonts-noto-cjk fonts-noto-color-emoji fonts-wqy-microhei \
    && sed -i '/zh_CN.UTF-8/s/^# //g' /etc/locale.gen \
    && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen \
    && update-locale LANG=zh_CN.UTF-8 LC_CTYPE=zh_CN.UTF-8 \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && fc-cache -fv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG=zh_CN.UTF-8
ENV LANGUAGE=zh_CN:zh
ENV LC_CTYPE=zh_CN.UTF-8

# 系统基础
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates gnupg bash bash-completion command-not-found \
    vim nano less procps psmisc lsof curl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 开发工具集
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc g++ make cmake git gh \
    ninja-build pkg-config just bubblewrap \
    clang clangd lldb gdb valgrind \
    python3 python3-pip python3-dev pipx python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 文件处理与搜索
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget unzip p7zip-full xz-utils zip tar file zstd \
    ripgrep fd-find fzf jq bat \
    && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
    && ln -sf /usr/bin/batcat /usr/local/bin/bat \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 网络与系统工具
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux htop btop tree \
    iproute2 iputils-ping dnsutils net-tools traceroute whois \
    openssh-client rsync netcat-openbsd telnet socat openssl \
    nmap tcpdump mtr-tiny iftop iperf3 avahi-utils \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Python 包管理器 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Node.js pnpm
ARG NODE_MAJOR=24

ENV PNPM_HOME=/pnpm
ENV PATH="/root/.local/bin:${PNPM_HOME}:${PATH}"

RUN curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | bash - \
    && apt-get update && apt-get install -y --no-install-recommends nodejs \
    && corepack enable \
    && corepack prepare pnpm@latest --activate \
    && pnpm config set global-bin-dir "${PNPM_HOME}" \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ------------------------------------------------------------
# 默认工具
# ------------------------------------------------------------
ENV EDITOR=vim
ENV VISUAL=vim
ENV PAGER=less
ENV LESS=-R

COPY --from=downloader /stage/claude /stage/codex /stage/opencode /root/.local/bin/

COPY bash.bashrc /etc/bash.bashrc

WORKDIR /workspace

CMD ["sleep", "infinity"]