const main_info* = """Interact with home Git servers more easily.

Usage:
  prigit <command>

Available commands:
  create [name]
    Creates a repository folder called [name] in the current directory.
  
  commit <message>
    Commits the changes in the current repository with an optional <message>.
  
  push
    Pushes the changes of the current repository."""

const create_info* = """Create Git repositories.

Usage:
  prigit create <name>

Creates a folder called <name> and runs git init inside."""