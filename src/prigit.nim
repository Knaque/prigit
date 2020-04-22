# Standard library
import os, parsecfg, parseopt, osproc, asyncdispatch
# Nimble
import elvis
# Files
import asyncssh, man
# module "man" is called with prefixes for the sake of comprehension

const version = "1.0.1"

# Custom types for consistency
type
  #  git action that the user wants to perform
  Action = enum
    None, Create, Commit, Push, Pull

  # information about the repo
  Repo = ref object
    name: string
    dir: string
  
  # information about ips
  Ip = ref object
    home: string
    global: string
    is_home: bool

# load prigit.cfg
let config = loadConfig(expandTilde("~/.prigit/prigit.cfg"))

var
  # init command line argument parser
  args = initOptParser(commandLineParams())
  
  # init some default arguments
  action: Action
  repo = Repo(name: "")
  ip = Ip(home: config.getSectionValue("", "homeIP"),
          global: config.getSectionValue("", "globalIP"),
          is_home: false)
  commit_message: string

# parse args
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
      of "home": ip.is_home = true
      of "msg": commit_message = arg.val
      of "help": echo man.main; quit 0
      of "version": echo "Prigit version " & version; quit 0
  of cmdShortOption:
    case arg.key
      of "n": repo.name = arg.val
      of "h": ip.is_home = true
      of "m": commit_message = arg.val
      of "v": echo "Prigit version " & version; quit 0
  of cmdEnd: discard

# get "username" from prigit.cfg
let username = config.getSectionValue("", "username")

# branching paths for different actions
case action
of Create:
  # ensure non-empty repo name
  if repo.name == "": echo man.create; quit 0

  # get current (working) directory
  let working_dir = getCurrentDir() & '/' & repo.name

  # set repo.dir to appropriate directory
  repo.dir = config.getSectionValue("", "gitFolder") & '/' & repo.name & ".git"

  # ssh into remove server and run appropriate commands (<3 treeform)
  echo waitFor execSSHCmd(username,
                          (ip.is_home == false ? ip.global ! ip.home),
                          "mkdir -p " & repo.dir & "; " &
                          "cd " & repo.dir & "; " &
                          "git init --bare")

  # create new directory for repo
  echo execProcess("mkdir -p " & working_dir)
  # initialize git repository
  echo execProcess("git init", working_dir)
  # add local ip to remotes
  echo execProcess("git remote add " & username & "_local " &
                   username & '@' & ip.home & ':' & repo.dir,
                   working_dir)
  # add remote ip to remotes
  echo execProcess("git remote add " & username & "_remote " &
                   username & '@' & ip.global & ':' & repo.dir,
                   working_dir)
of Commit:
  if commit_message == "": echo man.commit; quit 0 # ensure non-empty message
  else:
    # ensure all files are tracked
    echo execProcess("git add .")
    # git commit with message
    echo execProcess("git commit -a -m " & '"' & commit_message & '"')
of Push:
  case ip.is_home
  # git push to appropriate ip
  of false: echo execProcess("git push " & username & "_remote master")
  of true: echo execProcess("git push " & username & "_local master")
of Pull:
  case ip.is_home
  # git pull from appropriate ip
  of false: echo execProcess("git pull " & username & "_remote master")
  of true: echo execProcess("git pull " & username & "_local master")
of None: echo man.main