CURRENT_BG='NONE'
SEGMENT_SEPARATOR_RIGHT='\ue0b2'
SEGMENT_SEPARATOR_LEFT='\ue0b0'

ZSH_THEME_GIT_PROMPT_UNTRACKED=" ✭"
ZSH_THEME_GIT_PROMPT_DIRTY=''
ZSH_THEME_GIT_PROMPT_STASHED=' ⚑'
ZSH_THEME_GIT_PROMPT_DIVERGED=' ⚡'
ZSH_THEME_GIT_PROMPT_ADDED=" ✚"
ZSH_THEME_GIT_PROMPT_MODIFIED=" ✹"
ZSH_THEME_GIT_PROMPT_DELETED=" ✖"
ZSH_THEME_GIT_PROMPT_RENAMED=" ➜"
ZSH_THEME_GIT_PROMPT_UNMERGED=" ═"
ZSH_THEME_GIT_PROMPT_AHEAD=' ⬆'
ZSH_THEME_GIT_PROMPT_BEHIND=' ⬇'
ZSH_THEME_GIT_PROMPT_DIRTY=' ±'

_zsh2000_current_time_millis() {
    local time_millis
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        # Linux
        time_millis="$(date +%s.%3N)"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        time_millis="$(gdate +%s.%3N)"
    elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for Windows
    elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    elif [[ "$OSTYPE" == "win32" ]]; then
        # I'm not sure this can happen.
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        # ...
    else
        # Unknown.
    fi

    echo $time_millis
}

preexec() {
	_ZSH2000_COMMAND_TIME_BEGIN="$(_zsh2000_current_time_millis)"
}

prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_LEFT%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_segment_right() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
    echo -n "%K{$CURRENT_BG}%F{$1}$SEGMENT_SEPARATOR_RIGHT%{$bg%}%{$fg%} "
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR_LEFT"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}

prompt_user_hostname() {
  local user=`whoami`

  if [ -n "$SSH_CLIENT" ]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null)
    if [[ -n $dirty ]]; then
      prompt_segment magenta black
    else
      prompt_segment green black
    fi
    if [ "$ZSH_2000_DISABLE_GIT_STATUS" != "true" ];then
      echo -n "\ue0a0 ${ref/refs\/heads\//}$dirty"$(git_prompt_status)
    else
      echo -n "\ue0a0 ${ref/refs\/heads\//}$dirty"
    fi
  fi
}

prompt_dir() {
  prompt_segment blue white '%~'
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{yellow}%}✖"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

prompt_time() {
  prompt_segment_right white black '%D{%H:%M:%S} '
}

function displaytime {
  local T=$1
  local T2=${T%.*}
  local D=$((T2/1000/60/60/24))
  local H=$((T2/1000/60/60%24))
  local M=$((T2/1000/60%60))
  local S=$((T2/1000%60))
  local MS=$((T2%1000))
  (( $D >= 1 )) && echo -n "${D}d "
  (( $H >= 1 )) && echo -n "${H}h " 
  (( $M >= 1 )) && echo -n "${M}min " 
  (( $S >= 1 )) && echo -n "${S}s " 
  (( $MS >= 1 )) && echo "${MS}ms ⏳" 
  (( $MS < 1 )) && echo "0ms ⏳"
}


prompt_elapsed() {
	if [ "$_ZSH2000_COMMAND_TIME_BEGIN" = "-20200325" ] || [ "$_ZSH2000_COMMAND_TIME_BEGIN" = "" ]; then
            return 1
        fi
	local time_end="$(_zsh2000_current_time_millis)"
	local cost=$(bc -l <<<"(${time_end}-${_ZSH2000_COMMAND_TIME_BEGIN})*1000")
	local elapsed_millis=${cost%.*}
	_ZSH2000_COMMAND_TIME_BEGIN="-20200325"
	prompt_segment_right yellow black "${$(displaytime elapsed_millis)}"
}

build_prompt() {
  if [ "$ZSH_2000_DISABLE_STATUS" != 'true' ];then
    RETVAL=$?
    prompt_status
  fi
  prompt_user_hostname
  prompt_dir
  prompt_git
  prompt_end
}

ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT="%{$fg[green]%}"
ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM="%{$fg[yellow]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG="%{$fg[red]%}"
ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL="%{$fg[cyan]%}"
 
#Customized git status, oh-my-zsh currently does not allow render dirty status before branch
git_custom_status() {
  local cb=$(current_branch)
  if [ -n "$cb" ]; then
    echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX$(current_branch)$ZSH_THEME_GIT_PROMPT_SUFFIX"
  fi
}
 
# Determine the time since last commit. If branch is clean,
# use a neutral color, otherwise colors will vary according to time.
function git_time_since_commit() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Only proceed if there is actually a commit.
        if [[ $(git log 2>&1 > /dev/null | grep -c "^fatal: bad default revision") == 0 ]]; then
            # Get the last commit.
            last_commit=`git log --pretty=format:'%at' -1 2> /dev/null`
            now=`date +%s`
            seconds_since_last_commit=$((now-last_commit))
 
            # Totals
            MINUTES=$((seconds_since_last_commit / 60))
            HOURS=$((seconds_since_last_commit/3600))
           
            # Sub-hours and sub-minutes
            DAYS=$((seconds_since_last_commit / 86400))
            SUB_HOURS=$((HOURS % 24))
            SUB_MINUTES=$((MINUTES % 60))
            
            if [[ -n $(git status -s 2> /dev/null) ]]; then
                if [ "$MINUTES" -gt 30 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_LONG"
                elif [ "$MINUTES" -gt 10 ]; then
                    COLOR="$ZSH_THEME_GIT_TIME_SHORT_COMMIT_MEDIUM"
                else
                    COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_SHORT"
                fi
            else
                COLOR="$ZSH_THEME_GIT_TIME_SINCE_COMMIT_NEUTRAL"
            fi
 
            if [ "$HOURS" -gt 24 ]; then
                echo "($COLOR${DAYS}d${SUB_HOURS}h${SUB_MINUTES}m%{$reset_color%})"
            elif [ "$MINUTES" -gt 60 ]; then
                echo "($COLOR${HOURS}h${SUB_MINUTES}m%{$reset_color%})"
            else
                echo "($COLOR${MINUTES}m%{$reset_color%})"
            fi
        fi
    fi
}

prompt_return_code() {
  prompt_segment_right red yellow "$1 ✘"
}

precmd() {
	ZSH2000_RETURN_CODE=$?
}

build_rprompt() {
  if [[ -z "${ZSH2000_RETURN_CODE}" ]];then
    return 1
  fi

  if [[ $ZSH2000_RETURN_CODE != 0 ]];then
    prompt_return_code $ZSH2000_RETURN_CODE
  else
    prompt_elapsed
  fi
}


PROMPT='%{%f%b%k%}$(build_prompt) '
if [ "$ZSH_2000_DISABLE_RIGHT_PROMPT" != 'true' ];then
  RPROMPT='%{%f%b%k%}$(git_time_since_commit)$(build_rprompt)'
fi
