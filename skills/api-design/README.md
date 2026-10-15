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
4. Generates a complete spec file: OpenAPI 3.2 YAML (3.1 when the project's tooling lacks 3.2 support), `schema.graphql`, or `.proto`
5. Saves the output to `docs/api/`

### Review Mode (`/api-design --review`)

Audits an existing API against best practices:

1. Discovers existing API definitions via Glob (OpenAPI, Swagger, GraphQL schema, proto files, route files)
2. Checks REST best practices (naming, HTTP methods, versioning, pagination, error format, security)
3. Checks GraphQL best practices (descriptions, mutation return types, N+1, pagination patterns)
4. Flags breaking changes that would impact existing consumers
5. Outputs a severity-graded report with OWASP API Security Top 10 (2023 edition) mapping where relevant

---

## Supported Protocols

| Protocol | Output File | Format |
|----------|-------------|--------|
| REST | `docs/api/openapi.yml` | OpenAPI 3.2 YAML (3.1 fallback) |
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

All error responses use RFC 9457 Problem Details (`Content-Type: application/problem+json`), with `requestId` and field-level `errors` carried as extension members:

```json
{
  "type": "https://api.example.com/problems/validation-error",
  "title": "Request validation failed",
  "status": 422,
  "detail": "One or more fields are invalid.",
  "instance": "/v1/users",
  "requestId": "abc-123",
  "errors": [
    { "field": "email", "message": "Invalid email format" }
  ]
}
```

RFC 9457 replaced RFC 7807 in July 2023: <https://www.rfc-editor.org/rfc/rfc9457>. APIs that already ship a different envelope switch formats in their next major version, not in place.

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

## Rate Limiting

The skill recommends the IETF `RateLimit` and `RateLimit-Policy` header fields. They come from an Internet-Draft (draft-ietf-httpapi-ratelimit-headers, revision -11 as of May 2026), not a published RFC, so confirm the current syntax at <https://datatracker.ietf.org/doc/draft-ietf-httpapi-ratelimit-headers/>. The older `X-RateLimit-*` headers are accepted as legacy. 429 responses should always include `Retry-After`.

---

## Review Report Format

Findings are graded by severity:

- **CRITICAL** — breaking changes or security vulnerabilities (e.g., sensitive data in URLs, unauthenticated write endpoints)
- **HIGH** — significant contract violations or consistency issues
- **MEDIUM** — best practice deviations that cause friction
- **LOW** — minor naming inconsistencies or missing documentation

Each finding includes location, description, recommended fix, and an OWASP API Security Top 10 2023 ID (API1:2023 to API10:2023) where applicable.

---

## Example: Generated OpenAPI Snippet

```yaml
openapi: "3.2.1"
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
