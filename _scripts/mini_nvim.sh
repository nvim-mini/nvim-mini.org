# Make sure upstream is up to date. In case of error (like if there was force
# push), manually delete upstream directory and rerun `make` command.
git -C _deps/mini.nvim pull

# Clean copy necessary files with proper routing
rm -rf mini.nvim
mkdir -p mini.nvim

cp _deps/mini.nvim/README.md mini.nvim/index.md
cp _deps/mini.nvim/logo.png mini.nvim/logo.png
cp _deps/mini.nvim/CHANGELOG.md mini.nvim/CHANGELOG.md
cp _deps/mini.nvim/CONTRIBUTING.md mini.nvim/CONTRIBUTING.md
cp _deps/mini.nvim/TESTING.md mini.nvim/TESTING.md
mkdir -p mini.nvim/scripts
cp _deps/mini.nvim/scripts/init-deps-example.lua mini.nvim/scripts/init-deps-example.lua
cp -r _deps/mini.nvim/readmes mini.nvim/readmes
cp -r _deps/mini.nvim/doc mini.nvim/doc

# Adjust freshly copied files to better fit Quarto generation
nvim -l ./_scripts/mini_nvim.lua
