# Clean copy necessary files with proper routing
if [[ -d "MiniMax" ]]
then
  rm -rf MiniMax
fi

mkdir -p MiniMax
cp _deps/MiniMax/README.md MiniMax/index.md
cp _deps/MiniMax/logo.png MiniMax/logo.png
cp _deps/MiniMax/CHANGELOG.md MiniMax/CHANGELOG.md
cp -r _deps/MiniMax/configs MiniMax/configs
mv MiniMax/configs/README.md MiniMax/configs/index.md

nvim -l ./_scripts/minimax.lua
