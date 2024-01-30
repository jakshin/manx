These files are bundled into `manx` itself.

```bash
sed '/^[[:space:]]*# .*$/d' completion.zsh | sed 's|#[[:space:]].*$||g' |
	gzip --no-name --to-stdout | base64 --break=102 | pbcopy

gzip --no-name --to-stdout styles.css | base64 --break=102 | pbcopy
```
