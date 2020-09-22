# To install source this file from your .zshrc file

# see documentation at http://linux.die.net/man/1/zshexpn
# A: finds the absolute path, even if this is symlinked
# h: equivalent to dirname
export __GIT_PROMPT_DIR=${0:A:h}

export GIT_PROMPT_EXECUTABLE=${GIT_PROMPT_EXECUTABLE:-"python"}

# Initialize colors.
autoload -U colors
colors

# Allow for functions in the prompt.
setopt PROMPT_SUBST

autoload -U add-zsh-hook

add-zsh-hook chpwd chpwd_update_git_vars
add-zsh-hook preexec preexec_update_git_vars
add-zsh-hook precmd precmd_update_git_vars

## Function definitions
function preexec_update_git_vars() {
    case "$2" in
        git*|hub*|gh*|stg*)
        __EXECUTED_GIT_COMMAND=1
        ;;
    esac
}

function precmd_update_git_vars() {
    if [ -n "$__EXECUTED_GIT_COMMAND" ] || [ ! -n "$ZSH_THEME_GIT_PROMPT_CACHE" ]; then
        update_current_git_vars
        unset __EXECUTED_GIT_COMMAND
    fi
}

function chpwd_update_git_vars() {
    update_current_git_vars
}

function update_current_git_vars() {
    unset __CURRENT_GIT_STATUS

    if [[ "$GIT_PROMPT_EXECUTABLE" == "python" ]]; then
        local gitstatus="$__GIT_PROMPT_DIR/gitstatus.py"
        _GIT_STATUS=`python ${gitstatus} 2>/dev/null`
    fi
    if [[ "$GIT_PROMPT_EXECUTABLE" == "haskell" ]]; then
        _GIT_STATUS=`git status --porcelain --branch &> /dev/null | $__GIT_PROMPT_DIR/src/.bin/gitstatus`
    fi
     __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
	GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
	GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
	GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
	GIT_STAGED=$__CURRENT_GIT_STATUS[4]
	GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
	GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
	GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
}


git_super_status() {
	precmd_update_git_vars
	GIT_CHANGED_OR_UNTRACKED=$(expr $GIT_CHANGED + $GIT_UNTRACKED)
    if [ -n "$__CURRENT_GIT_STATUS" ]; then
	  STATUS="$ZSH_THEME_GIT_PROMPT_COLOR$ZSH_THEME_GIT_PROMPT_PREFIX$GIT_BRANCH"
	  if [ "$GIT_STAGED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_STAGED$GIT_STAGED"
	  fi
	  if [ "$GIT_CHANGED_OR_UNTRACKED" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_CHANGED_OR_UNTRACKED$GIT_CHANGED_OR_UNTRACKED"
	  fi
	  if [ "$GIT_BEHIND" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_BEHIND"
	  fi
	  if [ "$GIT_AHEAD" -ne "0" ]; then
		  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_AHEAD"
	  fi
	  if [ "$GIT_CONFLICTS" -ne "0" ]; then
		  STATUS="$STATUS $ZSH_THEME_GIT_PROMPT_CONFLICTS $GIT_CONFLICTS"
	  fi
	  STATUS="$STATUS$ZSH_THEME_GIT_PROMPT_SUFFIX%{${reset_color}%}"
	  echo "$STATUS"
	fi
}

# Default values for the appearance of the prompt. Configure at will.
ZSH_THEME_GIT_PROMPT_COLOR="%{$fg[yellow]%}"
ZSH_THEME_GIT_PROMPT_PREFIX="("
ZSH_THEME_GIT_PROMPT_SUFFIX=")"
ZSH_THEME_GIT_PROMPT_STAGED="+"
ZSH_THEME_GIT_PROMPT_CONFLICTS="CONFLICTS"
ZSH_THEME_GIT_PROMPT_BEHIND="↓"
ZSH_THEME_GIT_PROMPT_AHEAD="↑"
ZSH_THEME_GIT_PROMPT_CHANGED_OR_UNTRACKED="*"
