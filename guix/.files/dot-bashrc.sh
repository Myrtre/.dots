# Bash initialization for interactive non-login shells

export SHELL

if [[ $- != *i* ]]
then
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile
    
    return
fi

if [[ -e /etc/bashrc ]]; then
    source /etc/bashrc
fi

# Adjust the prompt depending we are in env or not
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi
