# git autocomplete and git repo prompt
. ~/.config/git/git-completion.bash
. ~/.config/git/git-prompt.bash
export GIT_PS1_SHOWDIRTYSTATE=1
export PS1='\w [rgasper@dgda1] $(__git_ps1 " (%s)")\$ '

