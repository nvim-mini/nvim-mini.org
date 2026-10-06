# Make sure upstream is up to date. In case of error (like if there was force
# push), manually delete upstream directory and rerun `make` command.
git -C _deps/assets pull

# Clean copy necessary files with proper routing
rm -rf assets/demo
rm -rf assets/logo-2

cp -r _deps/assets/demo assets/demo
cp -r _deps/assets/logo-2 assets/logo-2
