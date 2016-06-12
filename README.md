# git-helpers
Many two-letter bash commands that wrap git commands.

Import the file git_helpers.sh into your bash profile to start using immediately. 

The functions will only work in git diretories. For example, run "st" for "git status"

###The Basic Workflow:
1. Create a new branch for your task. 
```chn Name of a new branch```
  This creates a new branch with the name "Name-of-a-new-branch".

2. Edit some files.
  `st` = `git status`
  `dt` = `git difftool`

3. Commit your working changes with a short message.
  ```ca These are the things I changed```
  This makes a new commit with the given message adding files already known to git.

4. Repeat (2) and (3) as necessary.
  Making smaller commits and saving them as you go makes it easier to review your changes before sharing them with others.
  `lg` = `git log`
  This will repeat all the changes you've included so far.

5. Squash your intermediate changes into one commit to share. `sq` This squashes all the intermediate commits from steps (2), (3) and (4)

6. Share your commits with your teammates. 

### Working with Branches 

+ Read Branches with: `br`. This will pretty-print branches with the original names you created them with. For example: this might print:

```
(nts) Add new comments
(ges) Remove old images
(ter) master
```

+ Switch branches with a fuzzy search using `cj`. This switches to first branch that contains the given substring.
```
$ cj nts
Switched to branch 'Add-new-comments'
```

