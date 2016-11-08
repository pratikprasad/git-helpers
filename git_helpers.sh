# Import these in .bash_profile to start using immediately.

function st {
  git status
}

function lg {
  git log
}


#COLORS!
red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
purple=`tput setaf 5`
reset=`tput sgr0`
# Pretty print git branches.
function br {
  currentBranch=$(git rev-parse --abbrev-ref HEAD)
  branches=()
  eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/)"
  for branch in "${branches[@]}"; do
    # hacky way to get rid of programattic git branch formatting:
    # replace file separator '/' with new lines and pick the last token
    branchName=$(echo $branch | tr "/" "\n" | tail -n 1)
    if [[ $branchName =~ $currentBranch ]]; then
      echo "${purple}(${branchName: -3}) ${green}$branchName ${reset}" | tr "-" " "
    else
      echo "${purple}(${branchName: -3}) ${reset}$branchName" | tr "-" " "
    fi
  done
}

function brd {
  ch master
  git branch -d `branch_search $@`
}

function brdd {
  ch master
  git branch -D $@
}

function sp {
  git stash pop
}

function gs {
  git stash  $@
}

function sb {
  st
  br
}

function ch {
  git checkout $@
}




# A simplified fuzzy search - case insensitive search of all the git branches.
function branch_search {
  match="master"
  branches=()
  eval "$(git for-each-ref --shell --format='branches+=(%(refname))' refs/heads/)"
  for branch in "${branches[@]}"; do
    for var in "$@"
    do
        # TODO(pratik): extract into a separate function.
        setopt -s nocasematch
        if [[ $branch =~ $var ]]; then
          match=$(echo $branch | tr "/" "\n" | tail -n 1)
        fi
    done
  done
  echo $match
}
function bs { branch_search $@; } # shortened alias: bs
function cj { ch `bs $@`; } # fuzzy search to switch git branches
function rb { git rebase `bs $@`; }

function dt {
  git difftool $@
}

# Git rebasing branch to master
function rbm {
  CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
  echo 'Rebasing' $CUR_BRANCH 'against new master'
  cj master 
  git pull
  ch -
  git rebase master
  br
}

function dbb {
  CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
  rbm
  brd $CUR_BRANCH
}

function db {
  git pull --prune
  CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
  STATUS=`git status`
  EXPECTED="the upstream is gone" # HACK 
  if [[ $STATUS == *"$EXPECTED"* ]]; then
    ch master
    echo 'Deleting' $CUR_BRANCH "after a soft rebase"
    brdd $CUR_BRANCH
    git merge
    sb
  else 
    echo "The branch $CUR_BRANCH is not yet merged"
  fi
}

function join { local IFS="-"; echo "$*"; }

function chb {
  git checkout -b `join $@`
  git commit --allow-empty -m "$*"
}

function chn {
  cj master
  git pull
  chb $@
}

function ad {
  git add $@
}

function ac {
  ad $@
  git commit -v
}

function acm {
  ad $@
  git commit --amend -v
}

function aca {
  git commit --amend -av
}

# Add a new workflow for partial commits and squashing
function ca {
  git commit -am "$*"
}

function num_commits {
  git rev-list --count HEAD ^master
}

function sq {
  git rebase -i HEAD~`num_commits`
}

function remove_orig {
  rm `find -f  ./* | grep .*.orig`
}