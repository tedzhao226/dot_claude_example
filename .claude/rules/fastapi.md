# FastAPI

## Layered Architecture

```
Router → Service → Repository
```

### Router (API layer)
- Thin — parse request, call service, return response
- Pydantic schemas for request/response validation
- Use `Depends()` to inject services
- No business logic

### Service (business logic)
- All business rules and orchestration live here
- Receives repositories via constructor injection or `Depends()`
- Raises domain-specific exceptions
- No HTTP concepts (no Request/Response objects)

### Repository (data access)
- Database queries and mutations
- Returns domain models, not ORM objects to callers
- One repository per aggregate/resource

### Models & Schemas
- **Models**: SQLAlchemy ORM definitions
- **Schemas**: Pydantic request/response contracts (separate from ORM models)

## Project Structure

Small-to-mid (flat):
```
app/
├── main.py
├── models.py          # ORM models
├── schemas.py         # Pydantic schemas
├── services.py        # Business logic
├── repository.py      # Data access
├── api/
│   └── routes.py
└── core/
    ├── config.py
    └── dependencies.py
```

Larger (domain-module):
```
app/
├── main.py
├── core/
│   ├── config.py
│   └── database.py
├── <domain>/              # e.g. users/, orders/
│   ├── router.py
│   ├── service.py
│   ├── repository.py
│   ├── models.py
│   └── schemas.py
└── <domain>/
    └── ...
```

## References

- https://github.com/fastapi/full-stack-fastapi-template — Official FastAPI template
- https://github.com/zhanymkanov/fastapi-best-practices — FastAPI best practices (9k+ stars)
- https://github.com/nsidnev/fastapi-realworld-example-app — RealWorld example (Router/Service/Repository)
