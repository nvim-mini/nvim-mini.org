# General idea: check if respective `make` targets resulted in content
# change; if yes - add+commit them (separately for each target) with helpful
# commit messages

# 'mini.nvim'
if [[ `git status --porcelain -- mini.nvim/*` ]]; then
  commit=$(git -C _deps/mini.nvim rev-list -1 --abbrev-commit HEAD)
  git add mini.nvim/*
  git commit -m "feat(mini.nvim): sync to $commit"
fi

# MiniMax
if [[ `git status --porcelain -- MiniMax/*` ]]; then
  commit=$(git -C _deps/MiniMax rev-list -1 --abbrev-commit HEAD)
  git add MiniMax/*
  git commit -m "feat(minimax): sync to $commit"
fi

# Possibly show new commits
git log --oneline origin/main..HEAD
