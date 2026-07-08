# Python Checks

- [ ] Missing type hints on function signatures (Python 3.5+)
- [ ] No virtual environment documentation (`venv`, `poetry`, `pipenv`)
- [ ] `requirements.txt` without pinned versions (`==`)
- [ ] Mutable default arguments (`def foo(lst=[]): ...`)
- [ ] Bare `except:` clauses (catches everything including `KeyboardInterrupt`)
- [ ] `print()` statements in non-script code (use `logging`)
- [ ] No `__all__` in modules with public API
- [ ] Missing `if __name__ == "__main__":` guard in scripts
- [ ] F-string vs `%s` vs `.format()` inconsistency
- [ ] No linting config (`flake8`, `ruff`, `pylint`, `mypy`)

## Django (if detected)

- [ ] `DEBUG = True` not restricted to development
- [ ] `ALLOWED_HOSTS = ['*']` in production settings
- [ ] Raw SQL queries instead of ORM
- [ ] Missing `select_related`/`prefetch_related` (N+1 queries)
- [ ] No `__str__` method on models
- [ ] Signals used for business logic (hard to trace)
- [ ] No database indexes on frequently filtered/ordered fields

## FastAPI (if detected)

- [ ] Response models not defined (returns arbitrary dict)
- [ ] Missing request validation (Pydantic models not used)
- [ ] No dependency injection for auth/db
- [ ] Background tasks used for long-running work instead of a queue
