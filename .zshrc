# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

alias ll="ls -alF"

. "$(brew --prefix asdf)/libexec/asdf.sh"
fpath=($(brew --prefix asdf)/share/zsh/site-functions $fpath)
autoload -Uz compinit && compinit

# Powerlevel10k theme
source "$(brew --prefix)/share/powerlevel10k/powerlevel10k.zsh-theme"

# fzf
[ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh" ] && \
  source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
[ -f "$(brew --prefix)/opt/fzf/shell/completion.zsh" ] && \
  source "$(brew --prefix)/opt/fzf/shell/completion.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# search option
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# nvim remote
if [ -n "$NVIM" ]; then
	export GIT_EDITOR="nvr --remote-tab-wait +'set bufhidden=wipe'"
	export VISUAL="nvr --remote-tab-wait +'set bufhidden=wipe'"
	export EDITOR="nvr --remote-tab-wait +'set bufhidden=wipe'"
fi

# STIBEE_VARIABLE
export STIBEE_PATH="$HOME/works/stibee.com"
export STIBEE_OUTPUT_PATH="$HOME/works/stibee.com"
export SOPS_KMS_ARN="arn:aws:kms:actual_kms_key_arn"
export STIBEE_COMMON_SECRET="$STIBEE_PATH/queen/common/common_secret.enc.json"
