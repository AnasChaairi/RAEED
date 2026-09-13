# Notifications Spec

One pipeline, two priority lanes. SMS fallback for the critical lane is **confirmed in MVP** (`01-product-brief.md`), pulled forward from the product scope's V1 `NOT-05`.

## Lanes

| Lane | Events | Channel | User can disable? |
|---|---|---|---|
| **Critical** | Absence without notice (`ATT-07`), session change <24h out, urgent announcement | Push, immediate → **SMS fallback after 90s if undelivered** | No (`NOT-03`) |
| Normal | Presence confirmation, new homework, new message, new tagged post | Push | Per-category, yes |
| Low / grouped | New materials/summary, new album activity | Push, batched (e.g. "12 new photos") | Yes |

Every notification also lands in the in-app notification center with an unread counter, independent of push delivery — the center is the source of truth, push is just the interrupt.

## The critical-lane mechanism

See `02-architecture.md` for the full sequence diagram. Summary: attendance write → enqueue on the dedicated `critical` BullMQ queue (processed ahead of `normal`) → push via FCM → wait up to 90s for a delivery acknowledgement → SMS to the same guardians if no ack. Target SLA: p95 push dispatch under 30s from the write. This is the one number in the product that's a safety commitment — load-test it specifically (`11-testing-strategy.md`), don't infer it from unit tests.

## Notification catalog

| Event | Recipients | Lane |
|---|---|---|
| Presence confirmation requested | Parents of the group | Normal |
| Reminder: presence not answered | Parents who haven't answered | Normal |
| Child marked absent without notice | The child's guardians | **Critical** |
| Session cancelled or rescheduled | Parents and educators of the group | **Critical** if <24h out, else Normal |
| New homework | The child's guardians | Normal |
| Homework due tomorrow, not done | The child's guardians | Normal |
| New session materials/summary | Parents of the group | Low (grouped) |
| New message | Conversation members | Normal (respects the sending educator's `availability_hours_json` — arrives silently outside their window, MSG-07) |
| New post with my child tagged | Guardians of tagged children | Normal |
| New album/post activity | Parents of the group | Low (grouped) |
| New announcement | Target audience | Normal, or **Critical** if `priority: urgent` |
| Attendance not recorded on time | Educator, then executives | Normal |
| Profile change requested | Executives | Normal |
| Image consent changed | Executives + the child's educators | Normal (also triggers `consent-downgrade-recheck`, `07-backend-spec.md`) |

## Preferences

Everything except the Critical lane is toggleable per category in-app. The Critical set is exactly the three events listed above — not a vague "important stuff" bucket — so the notification-preferences screen has an unambiguous list to gray out.
