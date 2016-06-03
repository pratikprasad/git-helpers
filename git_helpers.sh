# Import these in .bash_profile to start using immediately.

function st {
  git status
}

function lg {
  git log
}


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
      echo "${blue}(${branchName: -3}) ${green}$branchName ${reset}" | tr "-" " "
    else
      echo "${blue}(${branchName: -3}) ${reset}$branchName" | tr "-" " "
    fi
  done
}

function brd {
  git branch -d `branch_search $@`
}

function brdd {
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
        shopt -s nocasematch
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

function gp {
  ch master
  git pull
}

function dt {
  git difftool $@
}

# Git rebasing branch to master
function rbm {
  CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
  echo 'Rebasing' $CUR_BRANCH 'against new master'
  gp
  ch -
  git rebase master
  br
}

function dbb {
  gp
  ch -
  echo 'Deleting' $CUR_BRANCH "after a soft rebase"
  db
}

function db {
  CUR_BRANCH=`git rev-parse --abbrev-ref HEAD`
  git rebase master
  ch master
  echo 'Deleting' $CUR_BRANCH "after a soft rebase"
  brd $CUR_BRANCH
  br
}


function join { local IFS="-"; echo "$*"; }

function chb {
  git checkout -b `join $@`
  git commit --allow-empty -m "$*"
}

function chn {
  gp
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

# Add a new workflow for partial commits and squashing
function ca {
  git commit -amv "$*"
}

function num_commits {
  git rev-list --count HEAD ^master
}

function sq {
  git rebase -i HEAD~`num_commits`
}
