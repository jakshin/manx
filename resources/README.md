These files are bundled into `manx` itself.

```bash
sed '/^[[:space:]]*# .*$/d' completion.zsh | sed 's|#[[:space:]].*$||g' | base64 --break=101 | pbcopy
base64 --break=112 -i styles.css | pbcopy
```
