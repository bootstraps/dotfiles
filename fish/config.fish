
# Set JAVA_HOME

if test -d /usr/libexec/java_home
    set -x JAVA_HOME (/usr/libexec/java_home)
end

# Set Grails Home

set -x GRAILS_HOME ~/workspace/grails-versions/grails-4.0.3

# Set PATH

set -x PATH /usr/local/bin $GRAILS_HOME/bin $PATH

# Set Groovy Home

set -x GROOVY_HOME /usr/local/opt/groovy/libexec

# Vim is my EDITOR

set -x EDITOR vim

# Set color

    set -x fish_color_cwd cyan
    set -x fish_color_autosuggestion 'bbb'
    set -x fish_color_quote red

# Reload Fish

function reload
  . ~/.config/fish/config.fish
end

# Postgres 

function pg_start
  pg_ctl -D /usr/local/var/postgres -l ~/workspace/pg_logfile start
end

function pg_stop
  pg_ctl -D /usr/local/var/postgres stop
end

# Mongo DB

abbr mongostart "mongod --config /usr/local/etc/mongod.conf"

# Custom prompt

  function fish_prompt -d "Write out the prompt"
    set -l arrow_color
    if test $status -eq 0
      set arrow_color (set_color cyan)
    else
      set arrow_color (set_color green)
    end

    # Create a prompt arrow.
    set -l arrow (echo -n -s "$arrow_color" '›' (set_color green))

    # Get the current ref, if any.
    set -l ref (git-current-branch)

    # Create a git_branch section for the prompt.
    set -l git_branch
    if test "$ref"
      set git_branch (echo -n -s (set_color magenta) "$ref" (set_color normal) ' ')
    end

    set -l git_status (git-status-prompt)
    if test "$git_status"
      set git_status (echo -n -s "$git_status ")
    end

    switch $USER

      case root

      if not set -q __fish_prompt_cwd
        if set -q fish_color_cwd_root
          set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
        else
          set -g __fish_prompt_cwd (set_color $fish_color_cwd)
        end
      end

      echo -n -s "$__fish_prompt_cwd" (prompt_pwd) (set_color normal) '# '

      case '*'

      if not set -q __fish_prompt_cwd
        set -g __fish_prompt_cwd (set_color $fish_color_cwd)
      end

      echo -n -s -e "$git_branch" "$git_status" "$__fish_prompt_cwd" (prompt_pwd) (set_color normal) "\n$arrow "

    end
  end

  function git-status-prompt -d "Returns a string of symbols indicating the status of the current git directory."
    set -l symbol_clean (echo -n -s (set_color green) 'G' (set_color normal))
    set -l symbol_untracked (echo -n -s (set_color red) '?' (set_color normal))
    set -l symbol_added (echo -n -s (set_color green) '+' (set_color normal))
    set -l symbol_modified (echo -n -s (set_color yellow) '/' (set_color normal))
    set -l symbol_renamed (echo -n -s (set_color brown) '→' (set_color normal))
    set -l symbol_deleted (echo -n -s (set_color red) '-' (set_color normal))
    set -l symbol_deleted_unstaged (echo -n -s (set_color yellow) '-' (set_color normal))
    set -l __status

    set -l index (git status --porcelain ^ /dev/null)

    if test -z "$index" -a "$status" -eq "0"
      set __status (echo -n -s "$symbol_clean")
    else

      set -l untracked (for l in $index; echo $l; end | grep '^?? ')
      if test "$untracked"
        set __status (echo -n -s "$symbol_untracked$__status")
      end

      set -l modified (for l in $index; echo $l; end | grep '^ M \|^AM \|^ T \|^MM \|^RM ')
      if test "$modified"
        set __status (echo -n -s "$symbol_modified$__status")
      end

      set -l added (for l in $index; echo $l; end | grep '^A  \|^M  \|^MM ')
      if test "$added"
        set __status (echo -n -s "$symbol_added$__status")
      end

      set -l renamed (for l in $index; echo $l; end | grep '^R  \|^RM ')
      if test "$renamed"
        set __status (echo -n -s "$symbol_renamed$__status")
      end

      set -l deleted_unstaged (for l in $index; echo $l; end | grep '^ D ')
      if test "$deleted_unstaged"
        set __status (echo -n -s "$symbol_deleted_unstaged$__status")
      end

      set -l deleted (for l in $index; echo $l; end | grep '^D  \|^AD ')
      if test "$deleted"
        set __status (echo -n -s "$symbol_deleted$__status")
      end

      set -l unmerged (for l in $index; echo $l; end | grep '^UU ')
      if test "$unmerged"
        set __status (echo -n -s "$symbol_unmerged$__status")
      end

    end

    echo -s -n "$__status"
  end

  function git-current-branch -d "Returns the simplified current branch."
    echo -n -s (git symbolic-ref HEAD ^ /dev/null | sed 's/refs\/heads\///g')
  end

function create-branch 
	git fetch -p --tags; git checkout master; git pull; git checkout -b $argv; git push --set-upstream origin $argv;
end
