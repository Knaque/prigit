import os, parsecfg, parseopt, osproc, asyncdispatch, elvis
import asyncssh, command_info

const version = "1.0.0"

type
  Action = enum
    None, Create, Commit, Push, Pull

  Repo = ref object
    name: string
    dir: string

  UsedIp = enum
    Home, Global
  Ip = ref object
    home: string
    global: string
    used: UsedIp

let config = loadConfig(expandTilde("~/.prigit/prigit.cfg"))

var
  args = initOptParser(commandLineParams())
  
  action: Action
  repo = Repo(name: "")
  ip = Ip(home: config.getSectionValue("", "homeIP"), global: config.getSectionValue("", "globalIP"), used: Global)
  commit_message: string

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
      of "home": ip.used = Home
      of "msg": commit_message = arg.val
      of "help": echo main_info; quit 0
      of "version": echo "Prigit version " & version; quit 0
  of cmdShortOption:
    case arg.key
      of "n": repo.name = arg.val
      of "h": ip.used = Home
      of "m": commit_message = arg.val
      of "v": echo "Prigit version " & version; quit 0
  of cmdEnd: discard

let username = config.getSectionValue("", "username")

case action
of Create:
  case repo.name
  of "":
    echo create_info; quit 0
  else: discard

  let working_dir = getCurrentDir() & '/' & repo.name

  repo.dir = config.getSectionValue("", "gitFolder") & '/' & repo.name & ".git"

  echo waitFor execSSHCmd(username, (ip.used == Global ? ip.global ! ip.home), "mkdir -p " & repo.dir & "; " & "cd " & repo.dir & "; " & "git init --bare")

  echo execProcess("mkdir -p " & working_dir)
  echo execProcess("git init", working_dir)
  echo execProcess("git remote add " & username & "_local " & username & '@' & ip.home & ':' & repo.dir, working_dir)
  echo execProcess("git remote add " & username & "_remote " & username & '@' & ip.global & ':' & repo.dir, working_dir)
of Commit:
  case commit_message
  of "": echo commit_info; quit 0
  else:
    echo execProcess("git add .")
    echo execProcess("git commit -a -m " & '"' & commit_message & '"')
of Push:
  case ip.used
  of Global: echo execProcess("git push " & username & "_remote master")
  of Home: echo execProcess("git push " & username & "_local master")
of Pull:
  case ip.used
  of Global: echo execProcess("git pull " & username & "_remote master")
  of Home: echo execProcess("git pull " & username & "_local master")
of None: echo main_info