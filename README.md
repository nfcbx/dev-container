# dev-container

这是一个面向日常开发的容器镜像。默认工作目录是 `/workspace`，容器启动后会持续运行，适合作为常驻开发环境，把项目目录直接挂进去使用。

## 容器里有什么

- 基础系统工具：`bash`、`vim`、`curl`、`git`、`less`、`procps`、`lsof`
- 编译工具链：`build-essential`、`gcc`、`g++`、`cmake`、`make`、`ninja`、`clang`
- 调试与分析：`gdb`、`lldb`、`valgrind`
- Python 环境：`python3`、`pip`、`pipx`、`venv`
- Node.js 环境：`nodejs`、`pnpm`
- 常用工具：`uv`、`ripgrep`、`fd`、`fzf`、`jq`、`bat`、`tmux`、`htop`、`btop`
- 网络与排障工具：`ping`、`dnsutils`、`netstat`、`traceroute`、`openssh-client`、`rsync`、`tcpdump`、`nmap`
- 默认内置命令：`claude`、`codex`、`opencode`
- 中文与字体支持：中文 locale、Noto 中文和 emoji 字体、文泉驿字体

## 怎么用

### Docker Compose

在项目目录下创建 `docker-compose.yml`：

```yaml
services:
  dev:
    image: nfcbx/dev-container:latest
    container_name: dev
    hostname: dev
    user: root

    tty: true
    stdin_open: true
    init: true
    command: sleep infinity

    cap_add:
      - SYS_ADMIN
    security_opt:
      - seccomp:unconfined
      - apparmor:unconfined

    working_dir: /workspace
    volumes:
      - ./workspace:/workspace
      - ./config/.claude:/root/.claude
      - ./config/.codex:/root/.codex
      - ./config/.config/opencode:/root/.config/opencode
      - ./config/.vscode-server:/root/.vscode-server

    network_mode: bridge
```

```bash
docker compose up -d
docker compose exec dev bash
```

项目代码放 `./workspace/`，各工具的配置文件会自动挂载到容器内，重启容器后配置不丢失。