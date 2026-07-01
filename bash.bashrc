# ------------------------------------------------------------
# Bash Completion
# 系统级命令补全
# ------------------------------------------------------------
if [ -f /usr/share/bash-completion/bash_completion ]; then
    source /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion
fi

# ------------------------------------------------------------
# 历史记录设置
# ------------------------------------------------------------
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# 每次显示提示符前同步历史记录
# 适合容器里多个 shell 同时使用
PROMPT_COMMAND="history -a; history -c; history -r${PROMPT_COMMAND:+; $PROMPT_COMMAND}"

# ------------------------------------------------------------
# Bash 行为优化
# ------------------------------------------------------------

# 自动修正 cd 时的小拼写错误
shopt -s cdspell 2>/dev/null

# 支持 ** 递归匹配
shopt -s globstar 2>/dev/null

# 窗口大小变化后自动更新 rows / columns
shopt -s checkwinsize

# ------------------------------------------------------------
# Better prompt
#
# 显示效果类似：
#   root@dev-ubuntu:/workspace#
# ------------------------------------------------------------
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# ------------------------------------------------------------
# Useful aliases
# 常用 ls / clear 快捷命令
# ------------------------------------------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias c='clear'

# ------------------------------------------------------------
# 目录跳转别名
# ------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ------------------------------------------------------------
# grep 彩色输出
# ------------------------------------------------------------
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# ------------------------------------------------------------
# mkdir 默认创建多级目录
# ------------------------------------------------------------
alias mkdir='mkdir -p'

# ------------------------------------------------------------
# Ubuntu 包名兼容
#
# Ubuntu 中：
# - fd-find 包提供的命令通常是 fdfind
# - bat 包提供的命令通常是 batcat
# ------------------------------------------------------------
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
    alias fd='fdfind'
fi

if command -v batcat >/dev/null 2>&1 && ! command -v bat >/dev/null 2>&1; then
    alias bat='batcat'
fi

# ------------------------------------------------------------
# 删除、复制、移动文件前进行确认。
# ------------------------------------------------------------
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# 查询公网 IPv4
alias myip='curl -4 --max-time 5 ifconfig.me 2>/dev/null; echo'