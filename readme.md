# Launch a Coconut (jupyter) shell using nix

```
nix run github:bj0/nix-coconut#coco
```

# Install it in a nix profile

```
nix profile install github:bj0/nix-coconut#coco
```
then `> coco`

## NOTES
* requires nix with flakes enabled
* if you get an error about writing a lock file, use: `--no-write-lock-file`
  * the `--no-write-lock-file` is required to run from the github repo, running locally does not require it
* updated to coconut 3.1.0
* switched from experimental dream2nix to nixpkgs recipe
  * relys on python packages in nixpkgs, so latest not available, limited to 3.1.0
  * might switch back to dream2nix when it's more stable

* previously, the python used to run `coconut` was leaked to the environment, but no longer
