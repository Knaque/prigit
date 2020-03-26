import os, parsecfg, parseopt, osproc # standard library
import asyncssh # nimble modules
import command_info # custom module(s)

type
  Action = enum
    None, Create, Commit, Push, Pull

  Repo = ref object
    name: string
    dir: string

proc getCurrentDirOnly: string =
  let current_dir = getCurrentDir()
  var last_slash = 0
  for i, c in current_dir:
    if c == '/': last_slash = i
    result = current_dir[last_slash+1..current_dir.len.pred]

let config = loadConfig(expandTilde("~/.prigit/prigit.cfg"))

var
  args = initOptParser(commandLineParams())
  
  action: Action
  repo = Repo(name:getCurrentDirOnly())
  username = config.getSectionValue("", "sshPrefix")
  ip = config.getSectionValue("", "globalIP")

for arg in getopt(args):
  case arg.kind
  of cmdArgument:
    case arg.key
      of "create": action = Create
      of "commit": action = Commit
      of "push": action = Push
      of "pull": action = Pull
  of cmdLongOption:
    case arg.key
      of "name": repo.name = arg.val
      of "home": ip = config.getSectionValue("", "homeIP")
  of cmdShortOption:
    case arg.key
      of "n": repo.name = arg.val
      of "h": ip = config.getSectionValue("", "homeIP")
  of cmdEnd: discard

var address = config.getSectionValue("", "sshPrefix") & '@' & ip

repo.dir = config.getSectionValue("", "gitFolder") & '/' & repo.name

case action
of Create:
  discard execSSHCmd(username, ip, "echo hello")
  # echo server.command("mkdir -p " & repo.dir & ".git")
  # echo server.command("cd " & repo.dir & ".git")
  # echo server.command("git init --bare")

  let working_dir = getCurrentDir() & '/' & repo.name
  echo execProcess("mkdir -p " & working_dir)
  echo execProcess("git init", working_dir)
  echo execProcess("git remote add " & repo.name & ' ' & address & ':' & repo.dir)
of Commit: discard
of Push: discard
of Pull: discard
of None: echo main_info

# server.exit()