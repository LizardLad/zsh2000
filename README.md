ZSH2000
======

Powerline looking zsh theme with rvm prompt, git status and branch, current time, user, hostname, pwd, exit status, root and background job status.

Influenced heavily by [agnoster's theme](https://gist.github.com/3712874) and [jeremyFreeAgent's theme](https://github.com/jeremyFreeAgent/oh-my-zsh-powerline-theme)

### Prerequisites
    zsh config similar to https://wiki.debian.org/Zsh

### Installation

    git clone https://github.com/consolemaverick/zsh2000.git
    ln -s zsh2000.zsh-theme ~/.oh-my-zsh/themes/zsh2000.zsh-theme

Modify ~/.zshrc setting

    ZSH_THEME="zsh2000"

### Configuration

Place these above this line in your ~/.zshrc:

    ZSH_THEME="zsh2000"

Disable the right hand side prompt entirely

    export ZSH_2000_DISABLE_RIGHT_PROMPT='true'

Disable user@hostname

    export ZSH_2000_DEFAULT_USER='YOUR_USER_NAME'

Disable display of

1. exit status of your last command
2. whether or not you are root
3. whether or not there are background jobs running

by adding

    export ZSH_2000_DISABLE_STATUS='true'

Disable git status on top of plain git clean/dirty

    export ZSH_2000_DISABLE_GIT_STATUS='true'
