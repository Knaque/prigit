import os
proc getCurrentDirOnly: string =
  let current_dir = getCurrentDir()
  var last_slash = 0
  for i, c in current_dir:
    if c == '/': last_slash = i
    result = current_dir[last_slash+1..current_dir.len.pred]

echo getCurrentDir()
echo getCurrentDirOnly()