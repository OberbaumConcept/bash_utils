# checksum

Wrapper around md5sum, sha1sum, sha256sum. Just run

```bash
checksum <path-to-file>  <checksum>
```

and don't care about checksum type, formatting etc. Example:

```bash
checksum somefile a6011 fb154 da9bf 6a853 8b8d0 23c9c91
checksum: OK
```

## Requirements

- `bash` >= 4.0
- `md5sum`
- `sha1sum`  
- `sha256sum`
