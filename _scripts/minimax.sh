# Make sure upstream is up to date. In case of error (like if there was force
# push), manually delete upstream directory and rerun `make` command.
git -C _deps/MiniMax pull

# Clean copy necessary files with proper routing
rm -rf MiniMax
mkdir -p MiniMax

cp _deps/MiniMax/README.md MiniMax/index.md
cp _deps/MiniMax/logo.png MiniMax/logo.png
cp _deps/MiniMax/CHANGELOG.md MiniMax/CHANGELOG.md
cp -r _deps/MiniMax/configs MiniMax/configs
mv MiniMax/configs/README.md MiniMax/configs/index.md

# Adjust freshly copied files to better fit Quarto generation
nvim -l ./_scripts/minimax.lua
