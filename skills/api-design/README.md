# api-design — API Design and Review

**Command:** `/api-design`
**Category:** workflow
**Version:** 1.0.0

---

## Overview

The `api-design` skill helps you design new APIs from scratch or audit existing ones. It supports REST, GraphQL, and gRPC. Use it when starting a new service, adding endpoints to an existing API, or when you want an objective review of whether your API follows industry best practices.

---

## Two Modes

### Design Mode (`/api-design`)

Guides you through designing a complete API surface:

1. Gathers requirements: domain, consumers, protocol, auth mechanism
2. Models resources and maps them to HTTP methods (REST) or types/resolvers (GraphQL)
3. Designs request/response schemas, error contracts, pagination, and versioning
4. Generates a complete spec file: OpenAPI 3.1 YAML, `schema.graphql`, or `.proto`
5. Saves the output to `docs/api/`

### Review Mode (`/api-design --review`)

Audits an existing API against best practices:

1. Discovers existing API definitions via Glob (OpenAPI, Swagger, GraphQL schema, proto files, route files)
2. Checks REST best practices (naming, HTTP methods, versioning, pagination, error format, security)
3. Checks GraphQL best practices (descriptions, mutation return types, N+1, pagination patterns)
4. Flags breaking changes that would impact existing consumers
5. Outputs a severity-graded report with OWASP API Security Top 10 mapping where relevant

---

## Supported Protocols

| Protocol | Output File | Format |
|----------|-------------|--------|
| REST | `docs/api/openapi.yml` | OpenAPI 3.1 YAML |
| GraphQL | `docs/api/schema.graphql` | SDL (Schema Definition Language) |
| gRPC | `docs/api/<service>.proto` | Protocol Buffers v3 |

---

## REST Resource Modeling

The skill follows REST resource conventions:

- Resources are **plural nouns**: `/users`, `/orders`, `/products`
- Sub-resources use one level of nesting: `/users/:id/addresses`
- Deeper relationships use query params: `/orders?userId=123`

Standard CRUD mapping:

```
GET    /resources          → list (with filtering, sorting, pagination)
GET    /resources/:id      → get one (404 if missing)
POST   /resources          → create (201 + Location header)
PUT    /resources/:id      → full update (idempotent)
PATCH  /resources/:id      → partial update
DELETE /resources/:id      → delete (204 No Content)
```

---

## Error Format

All error responses use a consistent structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable description",
    "details": [
      { "field": "email", "message": "Invalid email format" }
    ],
    "requestId": "abc-123"
  }
}
```

Never expose stack traces or internal system details in error responses.

---

## Versioning

| Strategy | Example | When to use |
|----------|---------|-------------|
| URL path | `/v1/users` | Public APIs — most visible, easy to route |
| Header | `Accept: application/vnd.api+json;version=1` | Internal APIs — cleaner URLs |
| Query param | `/users?version=1` | Prototyping only — not recommended for production |

---

## Breaking Change Detection

In review mode, the skill flags these as **breaking changes** that require a version bump:

- Removing an endpoint or field
- Changing a field's type
- Making an optional field required
- Changing the HTTP method or path of an existing endpoint
- Changing the error response format

---

## Review Report Format

Findings are graded by severity:

- **CRITICAL** — breaking changes or security vulnerabilities (e.g., sensitive data in URLs, unauthenticated write endpoints)
- **HIGH** — significant contract violations or consistency issues
- **MEDIUM** — best practice deviations that cause friction
- **LOW** — minor naming inconsistencies or missing documentation

Each finding includes location, description, recommended fix, and OWASP API Security Top 10 mapping where applicable.

---

## Example: Generated OpenAPI Snippet

```yaml
openapi: "3.1.0"
info:
  title: Orders API
  version: "1.0.0"
paths:
  /v1/orders:
    get:
      summary: List orders
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
            default: 20
        - name: cursor
          in: query
          schema:
            type: string
      responses:
        "200":
          description: Paginated list of orders
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/OrderListResponse"
        "401":
          $ref: "#/components/responses/Unauthorized"
```

---

## Author

Doug Eubanks — [github.com/RealDougEubanks](https://github.com/RealDougEubanks)
