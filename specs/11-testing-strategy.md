# Testing Strategy

| Layer | Automated | Manual |
|---|---|---|
| Mobile | Unit tests on domain/application layers; widget tests on the five deep-dived screens in `06-mobile-app-spec.md` at minimum; E2E on login→home and mark-attendance-offline→sync | Exploratory pass per release on a real entry-level Android device, not only an emulator |
| Backend | Unit tests per service; integration tests per module against a real test-Postgres (not mocked); a contract test asserting live responses match `04-api/openapi.yaml` | — |
| Security | Every ability rule in `05-authorization.md` gets a test asserting both the allow *and* the deny case; OTP rate-limit tests; brute-force tests | External review before the CNDP declaration and before app-store submission |
| Safety-critical path | Load test on the absence-alert pipeline (`02-architecture.md`) specifically — assert the p95 <30s dispatch target under realistic concurrent-session load, not inferred from unit tests | Pilot-phase real-world check: confirm a test alert actually reaches a real phone with weak signal |
| Localization / RTL | Snapshot tests catch RTL layout regressions | A bilingual/trilingual reviewer reads every string in context — machine-plausible Arabic isn't the same as correct Arabic; a screen-reader pass in Arabic specifically |
| Accessibility | Automated contrast checks against `08-design-system/design-tokens.json` | Device-lab pass with text scaling at 130%+ |

## Non-negotiable test cases (write these first)

1. **Attendance conflict** — two devices mark the same child on the same session while offline; the later `recorded_at_client` wins, the loser gets `attendance.conflict`, not a silent overwrite.
2. **Absence alert fires exactly once** — a child marked `absent` with no prior `no`/declared-absence answer triggers the critical queue; a child with a prior `no` answer does not.
3. **Consent block at publish time** — a Memories Wall post tagging a `not_allowed` child is rejected with `memories.consent_blocked`.
4. **Consent downgrade re-check** — an already-published post is auto-hidden when a tagged child's consent later changes to `not_allowed`.
5. **Scope leakage** — an educator's token cannot read a child outside their `group_educator` assignment, even by guessing a UUID (`403`, not `404`, so the client can distinguish "not yours" from "doesn't exist" without leaking existence — confirm this is the intended behavior with the team, since some APIs deliberately return `404` for both to avoid resource-existence leaks; whichever is chosen, apply it consistently everywhere).
6. **Audit log immutability** — the application's DB role genuinely cannot `UPDATE`/`DELETE` `audit_log_entry` (test against the real grants, not just application code paths).
