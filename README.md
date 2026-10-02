Hello dear dotfiler.

Here's my macOS and Linux compatible dotfiles repo.

Use it, fork it, hack it... or don't :-)

## Install with cURL

`sh -c "$(curl -fsSL https://raw.githubusercontent.com/TXC/dotfiles/master/install/install.sh)"`

On a fresh machine this installs Homebrew, clones the repo to `~/.dotfiles`, and
then hands over to the checked out installer.

## Install from a checkout

Everything:

```sh
zsh install/install.sh
```

Or just the parts you care about:

```sh
zsh install/install.sh git ssh
```

Re-running is safe. Symlinks that already point to the right place are left
alone, so repeat installs don't litter your home directory with backup copies.
Anything that *is* in the way gets moved to `<file>.<timestamp>` first.

## Modules

| Module     | What it does                                          |
|------------|-------------------------------------------------------|
| `homebrew` | `brew update` + `brew bundle` from `install/Brewfile`, plus powerlevel10k |
| `macos`    | Runs `install/osx.sh` (skipped on Linux)              |
| `zsh`      | `~/.zshrc`                                            |
| `mackup`   | `~/.mackup.cfg`                                       |
| `python`   | `~/.pythonrc`                                         |
| `ssh`      | `~/.ssh/config`, plus directory and key permissions   |
| `vim`      | `~/.vimrc` and the `~/.vim` scratch directories       |
| `git`      | `~/.gitconfig` and its includes                       |
| `tmux`     | `~/.tmux.conf`                                        |

They run in that order — `homebrew` comes first because `zsh` expects
powerlevel10k to be there.

Each module is a standalone script, so this works too:

```sh
zsh install/modules/git.sh
```

## Layout

```
conf/                 the actual configuration files
install/
  install.sh          entry point: bootstrap, then run modules
  common.sh           shared helpers (link, backup, logging, platform checks)
  modules/            one script per tool
  Brewfile
  osx.sh              macOS defaults
zsh/                  sourced at shell startup by conf/zshrc.conf
```

Adding a tool means dropping its config in `conf/`, adding
`install/modules/<tool>.sh`, and listing it in the `MODULES` array in
`install/install.sh`.
