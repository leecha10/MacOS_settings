# .bashrc

# alias

alias h='peco-history'
alias pcd='peco-lscd'
alias c='peco-chrome-history'
alias cb='peco-chrome-bookmark'
alias g='peco-git-branch-checkout'
alias re='exec $SHELL -l'

# peco

# peco-history
# from http://qiita.com/yungsang/items/09890a06d204bf398eea by yungsang
export HISTCONTROL="ignoredups"
peco-history() {
  local NUM=$(history | wc -l)
  local FIRST=$((-1*(NUM-1)))

  if [ $FIRST -eq 0 ] ; then
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
    echo "No history" >&2
    return
  fi

  local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

  if [ -n "$CMD" ] ; then
    # Replace the last entry, "peco-history", with $CMD
    history -s $CMD

    if type osascript > /dev/null 2>&1 ; then
      # Send UP keystroke to console
      (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
    fi

    # Uncomment below to execute it here directly
    # echo $CMD >&2
    # eval $CMD
  else
    # Remove the last entry, "peco-history"
    history -d $((HISTCMD-1))
  fi
}

# peco-lscd
# from https://qiita.com/xtetsuji/items/05f6f4c1b17854cdd75b
peco-lscd() {
    local dir="$( find . -maxdepth 1 -type d | sed -e 's;\./;;' | peco )"
    if [ ! -z "$dir" ] ; then
        cd "$dir"
    fi
}

# peco-chrome-history - browse chrome history
peco-chrome-history() {
  local cols sep google_history open
  cols=$(( COLUMNS / 3 ))
  sep='{::}'

  if [ "$(uname)" = "Darwin" ]; then
    google_history="$HOME/Library/Application Support/Google/Chrome/Default/History"
    open=open
  else
    google_history="$HOME/.config/google-chrome/Default/History"
    open=xdg-open
  fi
  cp -f "$google_history" /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select substr(title, 1, $cols), url
     from urls order by last_visit_time desc" |
  awk -F $sep '{printf "%-'$cols's  %s\n", $1, $2}' |
  peco  --prompt "[url]" | sed 's#.*\(https*://\)#\1#' | xargs $open > /dev/null 2> /dev/null
}

# peco-chrome-bookmark
peco-chrome-bookmark() {
    ~/projects/settings/peco-chrome-bookmark.rb
}

# peco-git-branch-checkout
peco-git-branch-checkout() {
    local selected_branch_name="$(git branch -a | peco | tr -d ' ')"
    case "$selected_branch_name" in
            (*-\>*) selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*->(.*?)\/(.*)$/\2/;print')"  ;;
            (remotes*) selected_branch_name="$(echo ${selected_branch_name} | perl -ne 's/^.*?remotes\/(.*?)\/(.*)$/\2/;print')"  ;;
    esac
    if [ -n "$selected_branch_name" ]
    then
            BUFFER="git checkout ${selected_branch_name}"
            $BUFFER
    fi
    # zle clear-screen
}
