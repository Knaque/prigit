import os, osproc, parsecfg, strutils
import command_info



let config = loadConfig(expandTilde("~/.prigit/prigit.cfg"))

# Check for any arguments; If none, echo help message
try:
  discard paramStr(1)
except IndexError:
  echo main_info
  quit 0

case paramStr(1).toLowerAscii
of "create":
  try:
    let repo_name = paramStr(2)
    let repo_dir = getCurrentDir() & '/' & repo_name
    case existsOrCreateDir(repo_dir)
    of true: echo "Directory " & repo_dir & " already exists!"
    else:
      echo "Created directory " & repo_dir & '\n'
      echo execProcess("git init", repo_dir)
      let remote_dir = config.getSectionValue("", "sshPrefix") & '@' & config.getSectionValue("", "homeIP") & ':' & config.getSectionValue("", "gitFolder")
      discard execProcess("git remote add " & repo_name & ' ' & remote_dir, repo_dir)
      echo "Added remote ref\n"
      writeFile(repo_dir & "/README.md", "# " & repo_name)
      echo "Created README.md"
  except IndexError:
    echo create_help
of "commit":
  let repo = getCurrentDir()
  echo execProcess("git add .", repo)
  if commandLineParams().len > 1: echo execProcess("git commit -m " & '"' & paramStr(2) & '"', repo)
  else: echo execProcess("git commit", repo)
of "push":
  let repo = getCurrentDir()
  var repo_name: string
  for i, c in repo:
    var last_slash = 0
    if c == '/': last_slash = i
    repo_name = repo[last_slash+1..repo.len.pred]
  
  echo execProcess("git push " & repo_name & ' ' & "master")
