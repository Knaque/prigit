# prigit
A CLI tool for more easily interacting with home Git servers.

Prigit is **not** designed for production-ready use. If that's what you need, just use regular Git and SSH, as that's all Prigit does behind-the-scenes.
Prigit has very few safety checks, so ensure that you know what you're doing.

## Installation:
0. First, make sure your system supports the `amd64` architecture.
Then, make sure you have Git installed. `git --version`
1. Download the installer .zip from the Releases tab, and unzip it.
2. You can go ahead and edit `prigit.cfg` now, if you'd like. Fill each field with the appropriate information, then save it.
3. Run `installer.sh` in `sudo`. You *must* be in `sudo` in order for it to work.
This will create the directory `~/.prigit` and copy `prigit.cfg` inside it, then it will copy `prigit` (the executable) to `/usr/bin`.
4. That's it! Test your installation by running `prigit --version`. (If you didn't edit your `prigit.cfg`, earlier, you must do that now.)

## Use
Prigit has four commands (`create`, `commit`, `push`, and `pull`) and one flag (`-h`/`--home`).
- create | `prigit create -name=<name>`:
Creates a repository.
On the server, a the repository will be created in whatever location specified in `prigit.cfg`.
The client-side repository will be created in the same directory that the command is run.
- commit | `prigit commit -msg="<message>"`:
Commits your changes.
Basically the same as the normal `git commit` command. Makes sure all items in the directory are tracked, then commits the changes with the specified `<message>`.
- push | `prigit push`:
Pushes your commited changes to the server.
- pull | `prigit pull`:
Pulls any changes from the server.
- -h/--home | `prigit <command> -h`:
If you're connected to the same network as the server, you *must* use this flag. The only exception is for the commit command, since the flag serves no function.

[asyncssh.nim module by treeform](https://github.com/treeform/asyncssh), thank you very much for your help!