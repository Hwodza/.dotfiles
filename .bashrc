eval "$(oh-my-posh init bash --config ~/.config/ohmyposh/kushal.omp.json)"
neofetch
alias n="nvim"
alias v="nvim"
alias cd="z"
alias t="tmux"
s() {
  sesh connect "$(sesh list | fzf)"
}
export EDITOR="nvim"
eval "$(zoxide init bash)"
