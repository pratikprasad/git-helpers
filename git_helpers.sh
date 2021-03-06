#!/usr/bin/env bash
# Import these in .bash_profile to start using immediately.

function st {
  git status
}

function lg {
  git log
}

function suggestion {
  # Try to give a helpful hint
  #   Take out meaningless words
  #   Take the first 3 letters of the first word
  hint=$(echo $1 | tr "-" "\n" | grep -wiv "use\|a\|add\|for\|in\|remove\|the\|to" | head -n 1)
  trimmed=$(echo "${hint:0:3}")
  echo $trimmed
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
    branchName=$(echo $branch | tr "/" "\n" | tail -n 1)
    suggestion=$(suggestion $branchName)
    if [[ $branchName == $currentBranch ]]; then
      echo "${purple}(${suggestion}) ${green}$branchName${reset}" | tr "-" " " | tr "_" " "
    else
      echo "${purple}(${suggestion}) ${reset}$branchName" | tr "-" " " | tr "_" " "
    fi
  done
}

function brm {
  git branch -m `join $@`
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

function chna {
  chn $@
  git commit --amend --no-edit -a
}

function rr {
  gp -u
}

function pr {
  gp -u
  hh pull-request -m "$(current_branch | tr - " ")"
}

function ap {
  git add -p
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

function c {
  git commit -m "$*"
}

# Quickly add and commit everything with the given string as acommit message
function ca {
  git commit -am "$*"
}

function num_commits {
  git rev-list --count HEAD ^master
}

function sq {
  git rebase -i HEAD~`num_commits`
}

function td {
  git log -p -`num_commits` | grep -i todo
}

function remove_orig {
  rm `f .orig | grep -v gitignore | grep -v node_modules`
}


function changed_files {
    git diff --name-only
}
