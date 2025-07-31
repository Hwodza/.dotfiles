eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/kushal.omp.json)"
neofetch
# Start ssh-agent if not already running
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval "$(ssh-agent -s)"
  ssh-add ~/.ssh/id_github
fi

alias n="nvim"
alias v="nvim"
alias cd="z"
alias t="tmux"
s() {
  sesh connect "$(sesh list | fzf)"
}
export EDITOR="nvim"
eval "$(zoxide init bash)"
