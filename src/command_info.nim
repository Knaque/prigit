# Contains text strings used for help info

const main_info* = """Interact with home Git servers more easily.

Usage:
  prigit <command>

Commands:
  create -n/--name:<name>
    Creates a repository with the given [name].
    Example: prigit create --name:helloworld
  
  commit -m/--msg:<message>
    Commit the changes to the current repository with a <message>.
    Example: prigit commit -msg:"Updated dependencies"
    This is the only command that doesn't require the -h/--home flag.
  
  push
    Pushes the changes of the current repository
  
  pull
    Pulls the changes from the current repository.

Flags:
  -h/--home
    This flag must be used for every command, except commit, when connected to the same network as the server."""

const create_info* = """Create Git repositories.

Usage:
  create -n/--name:<name>
    Creates a repository with the given [name].
    Example: prigit create --name:helloworld"""

const commit_info* = """Commit to a repository.

Usage:
  commit -m/--msg:"<message>"
    Commit the changes to the current repository with a <message>.
    Example: prigit commit -msg:"Updated dependencies"
    This is the only command that doesn't require the -h/--home flag."""