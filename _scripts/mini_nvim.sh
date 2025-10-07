# Clean copy necessary files with proper routing
if [[ -d "mini.nvim" ]]
then
  rm -rf mini.nvim
fi

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

nvim -l ./_scripts/mini_nvim.lua
