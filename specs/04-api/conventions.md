# API Conventions

REST, versioned at the path (`/api/v1/...`). `openapi.yaml` in this folder is the generated-from source both the Flutter app and the React dashboard build their typed clients against — extend it as each module ships; don't let a route exist that isn't in the contract.

## Envelope

```json
// success — list endpoint
{
  "data": [ /* ... */ ],
  "page": { "cursor": "eyJpZCI6...", "has_more": true }
}

// success — single resource: the resource object directly, no wrapper

// error — every failure, same shape
{
  "error": {
    "code": "attendance.already_recorded",
    "message": "This child was already marked by Fatima Z. at 09:14.",
    "details": {}
  }
}
```

Cursor-based pagination everywhere — offset pagination breaks under concurrent writes on live lists like attendance or messages. Filtering uses query params matching the dashboard's own filters: `season_id`, `branch_id`, `category_id`, `group_id`.

## Auth

Every request except `/auth/otp/*` and `/auth/refresh` requires `Authorization: Bearer <access_token>` (15-minute JWT). Every mutating endpoint resolves an ability check (`05-authorization.md`) against the resource named in the path — never trusted from the request body or the client's claimed role.

## Error code catalog (extend as modules ship)

| Code | HTTP | Meaning |
|---|---|---|
| `auth.otp_invalid` | 401 | Wrong or expired OTP |
| `auth.otp_rate_limited` | 429 | Too many OTP requests for this number |
| `scope.forbidden` | 403 | Authenticated, but the resource is outside the caller's ability scope |
| `attendance.conflict` | 409 | Incoming `recorded_at_client` predates the server's current record — see the conflict rule in `03-domain-model/entities.md` |
| `attendance.unknown_child` | 422 | `child_id` isn't enrolled in this session's group |
| `memories.consent_blocked` | 422 | A tagged child's current `image_rights_level` is `not_allowed` |
| `children.last_guardian` | 409 | Attempted to unlink a child's only remaining guardian |
| `validation.failed` | 422 | DTO-level schema validation failure (class-validator) — `details` carries the field errors |

## Versioning

Breaking changes bump the path prefix (`/api/v2/...`); additive changes (new optional field, new endpoint) ship under the current version. No endpoint is removed while a shipped mobile build still calls it — the mobile release cadence, not the backend's, sets the deprecation window.

## What every endpoint must do, no exceptions

- Validate the request body against a DTO (class-validator) before touching any service.
- Resolve the ability check before running any query, not after.
- Never render `app_user.phone` to a non-executive role, in any payload (`MSG-06`).
- Log to `audit_log_entry` on every write to `child`, `consent_record`, `attendance_record` (corrections), and every executive read of a conversation or a child's `health_json`.
