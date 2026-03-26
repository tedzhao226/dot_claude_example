# Python

- Prefer Protocol over ABC for interfaces
- Use pydantic BaseModel for data, dataclass for plain structs
- Dependency injection: pass deps as constructor args, not globals/singletons
- Type hints on public functions; skip obvious internals
- `pathlib` over `os.path`
- No bare `except:` — catch specific exceptions
- Imports: stdlib → third-party → local
