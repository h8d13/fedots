alias q='exit'

# fish-style prompt path: /etc/archinstoo.d/somefolder -> /e/a/somefolder
# ~ kept, last component whole, dotdirs keep 2 chars. Runs via
# PROMPT_COMMAND into a var to avoid a fork per prompt.
short_pwd() {
	local p=${PWD/#"$HOME"/\~} out= seg
	local IFS=/
	local -a parts=($p)
	local last=${parts[-1]}
	unset 'parts[-1]'
	for seg in "${parts[@]}"; do
		if [[ $seg == .?* ]]; then
			out+=${seg:0:2}/
		else
			out+=${seg:0:1}/
		fi
	done
	SHORT_PWD=$out$last
	[[ -z $SHORT_PWD ]] && SHORT_PWD=/
}
PROMPT_COMMAND='short_pwd'
export PS1='\[\033[1;34m\]┌──[\[\033[0;36m\]\A\[\033[1;34m\]]─[\[\033[0m\]\u\[\033[1;34m\]@\[\033[0;36m\]\h\[\033[1;34m\]]─[\[\033[0;32m\]${SHORT_PWD}\[\033[1;34m\]]\n\[\033[1;34m\]└──╼ \[\033[0;36m\]$ \[\033[0m\]'
# stolen PS1 from ParrotOS
export PATH="$HOME/.local/bin:$PATH"

shopt -s autocd        # forget 'cd' still go into dir
shopt -s cdspell       # fix minor typos in cd
shopt -s dirspell      # same during completions
shopt -s globstar      # ** recursive globs

if ! shopt -oq posix; then
	if [[ -r /usr/share/bash-completion/bash_completion ]]; then
		. /usr/share/bash-completion/bash_completion
	fi
fi
