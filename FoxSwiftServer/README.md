# FoxSwiftServer

## Environment

### Xcode

- Xcode >= 16.2
- Swift >= 6.0

### Database

```bash
brew install postgresql

brew services start postgresql@14
```

- create db

```bash
createuser foxswiftdev

createdb foxswiftdb -O foxswiftdev -E utf8

psql -l
```
