# Launch a Coconut (jupyter) shell using nix

```
nix run github:bj0/nix-coconut --no-write-lock-file
```

## NOTES
* requires nix 2.4
* the `--no-write-lock-file` is required to run from the github repo, running locally does not require it
* updated to coconut 3.0.2
* using new *experimental* dream2nix
    * if it says something about "cannot find flake attribute", you may need to run: `nix run github:bj0/nix-coconut#coconut.resolve --no-write-lock-file`, so dream2nix will generate whatever it needs to generate.
    * if it still doesn't work, try adding `#coco` to the end of the url