# RAEED Platform — Vision and Product Scope

**Version** 0.2 (draft for review) · **Date** September 2026 · **Prepared for** the RAEED Association board · **Document owner** [name]

**Changes in 0.2:** the suggested age stages are replaced by RAEED's 8 categories (فئات), and the V2 release is removed.

> **How to read this document.** Every requirement has an ID (e.g., ATT-07), a priority, and a phase.
> **Must** means the release cannot ship without it. **Should** means important and planned for that release, but it can slip to a quick follow-up update. **Could** means nice to have.
> **MVP** is the first release and **V1** the second.
> Items marked **★** are improvements suggested beyond the original feature list. Appendix A shows where each original feature lives.

## Summary

RAEED is building a private mobile and web platform that connects three roles around each enrolled child: parents, educators (mo'atirin), and executives (moshrifin). The first release (MVP) organizes the association's categories (فئات), groups, and weekly sessions, handles presence confirmations and attendance with instant absence alerts, tracks homework, keeps session materials available for later review, provides safeguarded messaging and targeted announcements, hosts a private Memories Wall for activity photos and videos, and gives executives a dashboard and audit logs. The second release (V1) adds camps and events, enrollment, and fees.

## 1. Vision

### 1.1 Why RAEED exists

RAEED supports children and young people aged 5 to 18 alongside their schooling, through an Islamic educational approach: Quran learning, authentic hadith, noble character (akhlaq), and a rich portfolio of intellectual, practical, and life skills. The goal is that by 18, every young person is a sincere believer with a sharp mind and capable hands, righteous in themselves (صالح) and a source of good and reform for others (مصلح).

*Tagline:* صالح في نفسه، مصلح لغيره — "Upright in oneself, uplifting to others."

### 1.2 The platform in one sentence

The RAEED platform is a private, secure app that connects executives, educators, and parents around each child: it organizes groups and sessions, tracks attendance and homework, shares learning materials and memories, and keeps everyone informed, while protecting children's privacy.

### 1.3 The problem it solves

Associations like RAEED usually run on WhatsApp groups, paper attendance sheets, and scattered photo albums. This works at a small scale but creates recurring problems. Parents' phone numbers and children's photos are visible to everyone in a group and can be forwarded anywhere. Parents don't know in real time whether their child arrived. Session materials get lost in chat history. Educators, many of them volunteers, repeat the same messages again and again. And the board has no reliable data on attendance, engagement, or growth. *(To be confirmed against RAEED's current practices.)*

### 1.4 Objectives and success measures

The targets below are proposals for the first full season, to be validated by the board.

| Objective | Success measure (proposed target) |
|---|---|
| Parents have a clear, real-time view of their children | 80% of families activate their account within the first month; 70% of presence confirmations answered before the deadline |
| Educators spend less time on administration | Attendance recorded for 95% of sessions; marking attendance for a group takes under one minute |
| Executives lead with reliable data | Monthly dashboard reviewed at board meetings; attendance trends available for every group |
| Children are safe and their privacy is protected | 100% of children have recorded image consent before appearing in a post; every unannounced absence triggers a parent alert |
| Communication is responsive | Average educator reply time under 24 hours |

### 1.5 Guiding principles

| Principle | What it means in practice |
|---|---|
| Child safety first | Instant absence alerts, health information at hand, safeguarded communication, no private educator–child channels |
| Privacy by design | No phone numbers shown to other users, photos stay inside the app, need-to-know access, consent enforced by the app |
| Simple for every parent | Arabic first, voice notes, large buttons, anything important within three taps |
| Light for educators | Recurring sessions, one-tap attendance, templates; many educators are volunteers |
| Transparency | Parents see what their child learns; executives can oversee everything, and every sensitive action is logged |
| Real life over screen time | No endless feeds, no ads, no public rankings; the app supports activities rather than replacing them |
| Sincerity (ikhlas) | Acts of worship are never turned into public competitions; each child is compared only with their own progress |

## 2. Users and roles

| Role | Who | Main needs | Where |
|---|---|---|---|
| Parent (ولي الأمر) | Mothers, fathers, and legal guardians of enrolled children | Know where their child is and what they learn, communicate easily, keep memories | Mobile app |
| Educator (مؤطر – mo'atir) | Group leaders and teachers, often volunteers | Plan sessions, take attendance quickly, reach parents, share materials and moments | Mobile app |
| Executive (مشرف – moshrif) | The association's management team | Oversee everything, communicate with everyone, decide with data | Web dashboard and mobile app |
| Admin ★ | One or two executives with configuration rights | Set up seasons, categories, groups, users, and settings; access logs | Web dashboard |

**Children** are not app users. Their information is managed by executives and parents, and they review learning materials on their parent's phone.

**Key relationships.** A family can have several children, and each child can have several guardians. In each season, a child belongs to one main group and possibly other groups (see open question Q3). A group can have several educators, and an educator can lead several groups. One person can hold several roles, such as an educator whose own children are enrolled.

## 3. Product scope

### 3.1 MVP modules

| Module | What it covers |
|---|---|
| Accounts and access | Invitation-only accounts, phone login, roles, consents |
| Association structure | Seasons, categories (فئات), groups, educator assignment, branches |
| Children and families | Child profiles with health information, guardians, parent home |
| Sessions and planning | Weekly sessions, materials, session summaries, cancellations, calendar |
| Presence and attendance | Presence confirmations, attendance marking, absence alerts |
| Homework | Assignment, tracking, reminders |
| Learning materials | Session files and videos kept for later review |
| Messaging | Child conversations, staff and executive channels, safeguarding rules |
| Announcements | Targeted announcements from executives and educators |
| Memories Wall | Private albums of photos, videos, and banners, with consent control |
| Notifications | Push notifications and a notification center |
| Dashboard and reports | Key statistics, filters, exports |
| Oversight and logs | Executive access and audit logs |

### 3.2 Second release (V1)

V1 adds events and camps (registration, digital parental authorization, live camp updates), enrollment and fees, homework submissions with feedback, authorized pick-up persons, repeated-absence alerts, and an end-of-season memory book.

### 3.3 Out of scope

Parent-to-parent messaging and public social features are excluded by design, to protect privacy. Accounts for children, online payments, live video classes, school grade tracking, a public website, and donation management are also out of scope for now.

## 4. Core concepts

| Concept | Description | Key information |
|---|---|---|
| Branch ★ | A center of the association. RAEED may start with one, but the model supports several. | Name, address, executives in charge |
| Season ★ | A school-year cycle (e.g., 2026–2027). Groups, enrollments, and albums belong to a season; past seasons are archived. | Start and end dates, status |
| Category (فئة) | An age level of the association containing one or more groups. RAEED has 8 categories (see §5.2). | Name, age range, gender |
| Group | Children following the same program with the same educators. | Name, category, season, capacity, weekly schedule, location, educators |
| Child | An enrolled child (not an app user). | Identity, photo, school level, groups, guardians, health information, consents |
| Guardian | A parent or legal guardian with an app account. | Name, phone, relationship, linked children |
| Educator | Leads one or more groups. | Name, phone, groups, availability hours |
| Executive | Oversees the association. | Name, permission level, branch scope |
| Session | One scheduled activity of a group. | Date, time, place, title, objectives, theme, materials, status |
| Material | A file or link attached to a session. | Type, visibility, size |
| Presence confirmation | A pre-session question sent to parents. | Session, answers, deadline |
| Attendance record | What actually happened for each child at a session. | Present, absent, late, or excused; time; recorded by |
| Homework | A task for a group or for specific children. | Instructions, attachments, due date, status per child |
| Conversation | A message thread. | Type (child, staff, executive), members, messages |
| Announcement | Official information sent to a target audience. | Audience, dates, priority, read statistics |
| Album and post | Photos, videos, or banners from activities. | Album, audience, tagged children, approval status |
| Consent record ★ | A guardian's recorded consent. | Type (privacy, image rights), level, date, version |
| Audit log entry | A record of a sensitive action. | Who, what, when, from which device |

## 5. Functional requirements

### 5.1 Accounts and access (ACC)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| ACC-01 | Three roles: Parent, Educator, Executive. Each role sees only what it is allowed to see (see §6). | Must | MVP |
| ACC-02 ★ | Invitation-only accounts. Executives register families and staff, and each person receives an invitation (SMS, WhatsApp, or email) to activate their account. There is no public sign-up, so nobody can pretend to be a parent. | Must | MVP |
| ACC-03 ★ | Login with a phone number and a one-time code (OTP), with email as an alternative. Users stay logged in on their own device. | Must | MVP |
| ACC-04 ★ | One person, several roles: an educator who is also a parent switches roles inside the same account. | Should | MVP |
| ACC-05 ★ | Several guardians per child (e.g., mother and father), each with their own account. Only executives can link or unlink a guardian, which matters in custody situations. | Must | MVP |
| ACC-06 ★ | Consent at first login: guardians accept the privacy policy and choose the image-rights level for each child (see WAL-06). Consents are dated and versioned, and can be changed at any time. | Must | MVP |
| ACC-07 ★ | Deactivating a user (e.g., an educator who leaves) removes their access on all devices immediately, while keeping their history. | Must | MVP |
| ACC-08 ★ | Two executive levels: Admin (configuration, users, logs) and Executive (oversight and communication), with optional restriction to one branch. | Should | MVP |
| ACC-09 ★ | Language chosen by each user: Arabic (right-to-left), French, or English. | Must | MVP |
| ACC-10 ★ | In-app requests for account deletion and for a copy of one's data, as expected by app store policies and data-protection law. | Must | MVP |

### 5.2 Association structure (ORG)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| ORG-01 ★ | Seasons: each school year is a season. Groups, enrollments, and albums belong to a season, and past seasons are archived, never deleted. | Must | MVP |
| ORG-02 | Categories (فئات): the association's 8 categories, each with an age range and gender (see the table below). Every group belongs to one category, and executives can rename or add categories without a developer. | Must | MVP |
| ORG-03 | Groups with name, category, season, capacity, weekly schedule, location, and educators. A group can have several educators, and an educator can lead several groups. | Must | MVP |
| ORG-04 ★ | Add, move, or remove children between groups, keeping the history (e.g., a child moved mid-season). | Must | MVP |
| ORG-05 ★ | Branches: the data model supports several centers from day one, even if RAEED starts with one. | Should | MVP |
| ORG-06 ★ | Bulk import of families, children, and groups from Excel for the initial setup. | Should | MVP |
| ORG-07 ★ | Substitute educator: temporary access to a group for specific dates. | Could | V1 |

**RAEED's categories (فئات).** The board completes the age range and gender of each category (see Q1).

| # | Category (فئة) | English | Age range | Gender |
|---|---|---|---|---|
| 1 | الأشبال | Cubs | to confirm | to confirm |
| 2 | النخبة | Elite | to confirm | to confirm |
| 3 | الفتية | Youths | to confirm | to confirm |
| 4 | اليافعون | Adolescents | to confirm | Boys |
| 5 | الصغار | Little ones | to confirm | to confirm |
| 6 | الفراشات | Butterflies | to confirm | to confirm |
| 7 | الزهرات | Flowers | to confirm | to confirm |
| 8 | اليافعات | Adolescents | to confirm | Girls |

### 5.3 Children and families (CHD)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| CHD-01 | Parent home: one card per enrolled child showing photo, name, age, group, educators, next session, and today's status (confirmed, absent, present). | Must | MVP |
| CHD-02 | Child profile: name, date of birth, photo, school and school level ★, groups, guardians and their contacts, emergency contacts ★, health information (allergies, conditions, medication, dietary needs ★), and special needs. | Must | MVP |
| CHD-03 | Educators see the full profile of children in their own groups only. ★ Health alerts appear as a badge next to the child's name in every list, including the attendance screen. | Must | MVP |
| CHD-04 ★ | Parents view their child's information and request corrections (e.g., a new allergy); an executive validates sensitive changes. | Must | MVP |
| CHD-05 | Parents see each child's attendance history and statistics (e.g., 18 of 20 sessions this season). | Should | MVP |
| CHD-06 ★ | Authorized pick-up persons for younger children (name, relationship, phone, photo), visible to educators. | Should | V1 |
| CHD-07 ★ | Educator notes, of two kinds: private staff notes (educators and executives only) and shared notes for parents (encouragement, observations). | Should | V1 |

### 5.4 Sessions and weekly planning (SES)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| SES-01 | Educators plan the week's sessions for each of their groups: date, time, place, title, objectives, and ★ theme. | Must | MVP |
| SES-02 ★ | Recurring sessions are created automatically from the group's weekly schedule, so educators only add the content. | Should | MVP |
| SES-03 | Educators attach materials to each session: documents, images, audio, video, and links. | Must | MVP |
| SES-04 ★ | Visibility per material: visible to parents before the session, after it, or to staff only (e.g., preparation notes). | Should | MVP |
| SES-05 ★ | A short session summary after each session ("What we did today"), optionally with photos, sent to the group's parents. | Should | MVP |
| SES-06 ★ | Cancel or reschedule a session; the group's parents and educators are notified automatically. | Must | MVP |
| SES-07 | Parents see the schedules of all their children in one calendar. | Must | MVP |
| SES-08 ★ | Hijri date shown next to the Gregorian date in calendars. | Could | MVP |
| SES-09 ★ | Duplicate a past session or start from a template, and share good sessions between educators. | Could | V1 |
| SES-10 ★ | Executives see all sessions across groups: planned, delivered, and cancelled. | Must | MVP |

### 5.5 Presence confirmation and attendance (ATT)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| ATT-01 | Presence confirmation: the educator sends a question for a session ("Will [child] attend on Saturday?"); parents receive a notification and answer. | Must | MVP |
| ATT-02 ★ | Answers are Yes, No, or Late, with an optional reason for absence (illness, travel, school exam, other). | Must | MVP |
| ATT-03 ★ | Automatic sending at a set time before each session (e.g., the evening before), with a deadline and one reminder to parents who haven't answered. | Should | MVP |
| ATT-04 ★ | Parents can declare an absence in advance at any time, without waiting for the question. | Should | MVP |
| ATT-05 ★ | Live summary for the educator (confirmed, absent, no answer) to plan materials, snacks, and transport. | Must | MVP |
| ATT-06 | Attendance marking: a one-tap list per session, pre-filled from the presence answers, with the statuses Present, Absent, Late, and Excused. ★ Works offline and syncs later. | Must | MVP |
| ATT-07 ★ | Absence alert: when a child is marked absent without prior notice, their guardians are notified immediately. This is a safety feature, since a parent may believe the child is at the association. | Must | MVP |
| ATT-08 ★ | Reminder to the educator if attendance is not recorded within a set time (e.g., 30 minutes after the start); executives see sessions with missing attendance. | Should | MVP |
| ATT-09 ★ | Repeated absences (e.g., three in a row) flag the child to educators and executives for a caring follow-up. | Should | V1 |
| ATT-10 ★ | Check-out record when a younger child is picked up: who picked them up, and when. | Could | V1 |

### 5.6 Homework (HWK)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| HWK-01 | Educators assign homework to a whole group or ★ to specific children, linked to a session, with instructions, attachments, and a due date. | Must | MVP |
| HWK-02 | Parents see each child's homework with its status and due date. | Must | MVP |
| HWK-03 ★ | Parents mark homework as done. | Must | MVP |
| HWK-04 ★ | Reminder the day before the due date if the homework is not marked as done. | Should | MVP |
| HWK-05 ★ | Completion rate per group for educators and executives. | Should | MVP |
| HWK-06 ★ | Submission of a photo, audio (e.g., a recitation), or video, with educator feedback and encouragement. No public ranking. | Should | V1 |

### 5.7 Learning materials (MAT)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| MAT-01 | Parents access the files, videos, and links of past sessions, so the child can review and learn more at home. | Must | MVP |
| MAT-02 ★ | A library per child gathering all materials from their groups, searchable and filterable by type, theme, and date. | Should | MVP |
| MAT-03 ★ | Size and format limits (e.g., short videos uploaded, long videos shared as links) to control storage costs. | Must | MVP |
| MAT-04 ★ | Download audio and PDF files for offline use. | Could | V1 |
| MAT-05 ★ | A shared association library curated by executives (e.g., approved recitations, authentic hadith collections) that every educator can reuse. | Could | V1 |
| MAT-06 ★ | Review of religious content by a designated scholarly reviewer before publication. | Could | V1 |

### 5.8 Messaging (MSG)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| MSG-01 | Parent–educator conversations. ★ Organized as one conversation per child that includes the child's guardians and all educators of the child's group, so everyone sees the same thread and nothing depends on one person. | Must | MVP |
| MSG-02 | Executive–parent and executive–educator conversations. | Must | MVP |
| MSG-03 ★ | A staff channel per group for co-educators and executives to coordinate. | Should | MVP |
| MSG-04 ★ | Messages can contain text, photos, and files. | Must | MVP |
| MSG-05 ★ | Voice notes, for parents who are more comfortable speaking than typing. | Should | MVP |
| MSG-06 ★ | Phone numbers are never shown to other users, and there is no parent-to-parent messaging. | Must | MVP |
| MSG-07 ★ | Educator availability hours (e.g., 9:00–20:00). Messages sent outside these hours arrive silently, and the parent sees an automatic note with the association's contact for urgent matters. | Should | MVP |
| MSG-08 ★ | Safeguarding: no private educator–child channel; executives can read conversations for oversight (disclosed in the terms of use); messages can be hidden but never permanently deleted. | Must | MVP |
| MSG-09 ★ | Read receipts and unread counters. | Should | MVP |
| MSG-10 ★ | Any user can report a message; executives can mute or restrict a user. | Should | MVP |

### 5.9 Announcements (ANN)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| ANN-01 | Executives publish announcements that appear on the home page of parents and educators and are sent as push notifications. | Must | MVP |
| ANN-02 ★ | Target audience: everyone, parents only, educators only, or specific branches, categories, or groups. | Must | MVP |
| ANN-03 ★ | Educators publish announcements to their own groups (e.g., "Bring sports clothes on Saturday"). | Must | MVP |
| ANN-04 ★ | Images, banners, and attachments. | Should | MVP |
| ANN-05 ★ | Schedule for later, set an expiry date, and pin to the top. | Should | MVP |
| ANN-06 ★ | Read statistics, and an "I have read this" confirmation for important notices. | Should | MVP |
| ANN-07 ★ | Urgent mode (e.g., a cancellation due to weather, an emergency during a camp): high-priority notification with SMS fallback. | Should | V1 |
| ANN-08 ★ | Simple polls (e.g., choosing a date for a parents' meeting). | Could | V1 |

### 5.10 Memories Wall (WAL)

*Renamed from "memorial wall": in English, "memorial" usually refers to honoring people who have died. "Memories Wall" (جدار الذكريات) matches the intent.*

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| WAL-01 | Educators share photos, videos, and banners from sessions, trips, and camps. | Must | MVP |
| WAL-02 | Parents see the posts of their children's groups. | Must | MVP |
| WAL-03 ★ | Albums per event or camp (e.g., "Spring Camp 2027"), organized by season, with a timeline view. | Should | MVP |
| WAL-04 ★ | Educators tag the children in a post; parents can filter to "Photos of my child". | Should | MVP |
| WAL-05 ★ | Private audience: posts are visible only to the parents of the groups or participants concerned, never public, with no "share outside the app" button. | Must | MVP |
| WAL-06 ★ | Image-rights level per child: Allowed (app and association communication), App only, or Not allowed. The level appears on the tagging screen, and tagging a child marked Not allowed blocks the post until the photo is removed. | Must | MVP |
| WAL-07 ★ | Moderation: optional executive approval before publishing, and executives can hide any post. | Should | MVP |
| WAL-08 ★ | Celebration banners from ready-made templates (e.g., completing a surah or a camp). | Could | MVP |
| WAL-09 ★ | Reactions from parents; comments are off by default and can be enabled by executives. | Could | MVP |
| WAL-10 ★ | Automatic compression of photos and length limits for videos. | Must | MVP |
| WAL-11 ★ | Parents can download the photos in which their own child is tagged. | Could | V1 |
| WAL-12 ★ | End-of-season memory book: an automatically generated PDF album for each child. | Could | V1 |

### 5.11 Notifications (NOT)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| NOT-01 ★ | A notification center listing all notifications, with an unread counter. | Must | MVP |
| NOT-02 ★ | Push notifications for the events listed in §7. | Must | MVP |
| NOT-03 ★ | Preferences per notification category. Critical alerts (absence alerts, urgent announcements) cannot be turned off. | Should | MVP |
| NOT-04 ★ | Low-priority notifications are grouped (e.g., "12 new photos in Spring Camp") to avoid overload. | Should | MVP |
| NOT-05 ★ | SMS fallback for critical alerts when the app is not installed or the phone is offline. | Could | V1 |

### 5.12 Dashboard and reports (DSH)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| DSH-01 | Overview: number of children, families, groups, and educators, broken down by branch, category, group, and gender. | Must | MVP |
| DSH-02 | Attendance: rate by category, group, educator, and child, with weekly trends. | Must | MVP |
| DSH-03 ★ | Filters by season, date range, branch, category, and group. | Must | MVP |
| DSH-04 ★ | Educator activity: sessions planned versus delivered, attendance recorded on time. | Should | MVP |
| DSH-05 ★ | Engagement: parent account activation rate, presence-confirmation response rate, homework completion, average reply time to messages. | Should | MVP |
| DSH-06 ★ | Alerts panel: sessions without attendance, groups over capacity, and (from V1) children with repeated absences. | Should | MVP |
| DSH-07 ★ | Export to Excel and PDF (for the general assembly, funding partners, and insurance lists for trips). | Should | MVP |

### 5.13 Oversight and audit logs (AUD)

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| AUD-01 | Executives can access all groups, children, parents, files, posts, and conversations. | Must | MVP |
| AUD-02 | Activity log of sensitive actions (logins, creations, edits and deletions, posts, hidden messages, exports, consent changes), recording who, what, and when. | Must | MVP |
| AUD-03 ★ | Access log for sensitive data: who viewed a child's health information. | Should | MVP |
| AUD-04 ★ | Logs cannot be edited, even by executives, and are kept for a defined period (see §11). | Should | MVP |

### 5.14 Events and camps (EVT) ★

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| EVT-01 ★ | Create an event or camp: dates, place, categories or groups concerned, capacity, price, program, and packing list. | Should | V1 |
| EVT-02 ★ | Parents register their child in the app, with a waiting list when the event is full. | Should | V1 |
| EVT-03 ★ | Digital parental authorization signed in the app, with confirmation of health information and emergency contacts. | Should | V1 |
| EVT-04 ★ | Participant lists with health information, emergency contacts, and pick-up persons, exportable for insurance and transport. | Should | V1 |
| EVT-05 ★ | Live camp updates for parents ("We arrived safely") and an automatic album on the Memories Wall. | Should | V1 |
| EVT-06 ★ | Headcount check at departure, at return, and at each stop. | Could | V1 |

### 5.15 Enrollment and fees (ENR) ★

| ID | Requirement | Priority | Phase |
|---|---|---|---|
| ENR-01 ★ | Re-enrollment for the next season from the app. | Should | V1 |
| ENR-02 ★ | New enrollment requests (e.g., a younger sibling) reviewed by executives, with a waiting list. | Should | V1 |
| ENR-03 ★ | Fee tracking per family (amount due, paid, remaining, receipts), with payments recorded by executives (cash or transfer). | Should | V1 |
| ENR-04 ★ | Payment reminders. | Could | V1 |

## 6. Permissions by role

| Action | Parent | Educator | Executive |
|---|---|---|---|
| View a child's profile | Own children | Children in own groups | All |
| Edit a child's profile | Request changes | Staff notes only | Yes |
| View health information | Own children | Own groups | All (logged) |
| Manage seasons, categories, groups, and users | No | No | Admin only |
| Plan sessions and upload materials | No | Own groups | All groups |
| Send presence confirmations | No | Own groups | All groups |
| Answer presence confirmations, declare absences | Own children | No | No |
| Mark attendance | No | Own groups | All groups (corrections are logged) |
| Assign homework | No | Own groups | All groups |
| Mark homework as done | Own children | No | No |
| Access session materials | Own children's groups | Own groups | All |
| Send messages | To educators of own children and to executives | To parents of own groups, co-educators, and executives | Everyone |
| Read all conversations | No | No | Yes (logged and disclosed) |
| Post on the Memories Wall | No | Own groups | Yes |
| View the Memories Wall | Own children's groups | Own groups | All |
| Moderate posts | No | Own posts | All posts |
| Publish announcements | No | Own groups | Any audience |
| View statistics | Own children's attendance | Own groups | Everything |
| Export data | No | No | Yes (logged) |
| View audit logs | No | No | Admin only |

## 7. Notification catalog

| Event | Recipients | Priority |
|---|---|---|
| Presence confirmation requested | Parents of the group | Normal |
| Reminder: presence not answered | Parents who haven't answered | Normal |
| Child marked absent without notice | The child's guardians | High (cannot be turned off) |
| Session cancelled or rescheduled | Parents and educators of the group | High |
| New homework | The child's guardians | Normal |
| Homework due tomorrow and not done | The child's guardians | Normal |
| New session materials or summary | Parents of the group | Low (grouped) |
| New message | Conversation members | Normal |
| New post with my child tagged | Guardians of tagged children | Normal |
| New album or posts in a group | Parents of the group | Low (grouped) |
| New announcement | Target audience | Normal, or High if urgent |
| Attendance not recorded on time | The educator, then executives | Normal |
| Profile change requested by a parent | Executives | Normal |
| Image consent changed | Executives and the child's educators | Normal |

## 8. Key user journeys

### 8.1 A family joins the platform

1. An executive creates the family (or imports it from Excel): guardians, children, health information, and group.
2. Each guardian receives an invitation by SMS or WhatsApp with a link to install the app.
3. The guardian logs in with their phone number and a one-time code.
4. They check their children's information, accept the privacy policy, and choose the image-rights level for each child.
5. They land on the home screen: one card per child, the next sessions, and current announcements.

### 8.2 A week in the life of a group

1. Early in the week, the educator opens the Saturday session (already created from the weekly schedule) and adds objectives and materials, some visible now and some only after the session.
2. The evening before, the presence confirmation goes out automatically, and parents who haven't answered get one reminder.
3. The educator checks the summary: for example, 18 confirmed, 2 absent (one ill, one travelling), and 3 without an answer.
4. On Saturday, the attendance list is pre-filled from the answers, and the educator confirms each child with one tap, even offline.
5. If a child is missing without notice, their guardians receive an absence alert immediately.
6. After the session, the educator publishes a short summary, assigns homework, and posts a few photos to the Memories Wall.
7. During the week, parents review the materials with their child and mark the homework as done.

### 8.3 Sharing memories from a camp

1. The educator selects photos and videos, chooses the album (e.g., "Spring Camp 2027"), and tags the children.
2. The app checks consents: tagging a child whose image rights are "Not allowed" blocks the post until that photo is removed.
3. If approval mode is on, an executive approves the post.
4. The post becomes visible to the parents concerned, and guardians of tagged children are notified.
5. Parents react and can filter the album to see only the photos of their child.

### 8.4 An executive announcement

1. The executive writes the announcement, adds a banner, and chooses the audience (e.g., parents of the الأشبال category), the publishing date, and the expiry date.
2. Recipients get a push notification, and the announcement appears on their home screen.
3. The executive follows the read rate and, for important notices, the list of people who confirmed reading.

### 8.5 A parent writes to the educators

1. The parent opens their child's conversation and sends a text or a voice note.
2. All educators of the child's group see the message, and one of them replies.
3. Outside availability hours, the parent sees an automatic note with the association's contact for urgent matters.
4. Executives can view the thread for oversight.

## 9. App structure by role

| Role | Main sections |
|---|---|
| Parent (mobile) | Home (child cards, today's status, announcements) · Calendar · Messages · Memories · More (settings, consents, help). Tapping a child opens their page: profile, schedule, attendance, homework, materials. |
| Educator (mobile) | Today (today's sessions, presence summary, attendance) · Groups (children, sessions, homework, materials) · Messages · Memories · More |
| Executive (web) | Dashboard · Structure (seasons, categories, groups) · People (children, families, staff) · Sessions · Announcements · Memories moderation · Messages · Reports · Logs · Settings |
| Executive (mobile) | Dashboard · Announcements · Messages · Memories · Groups |

## 10. Non-functional requirements

| Area | Requirement |
|---|---|
| Platforms | iOS and Android apps for all roles, plus a web dashboard for executives. The apps must run well on entry-level Android phones, which many families use. |
| Languages | Arabic (right-to-left), French, and English, chosen by each user. The Hijri date appears next to the Gregorian date, with a manual adjustment of one day so executives can follow the official calendar. |
| Ease of use | Designed for parents with limited digital experience: icons with text, large buttons, voice notes, minimal typing, and anything important within three taps. |
| Speed | Main screens load in under two seconds on a normal 4G connection; images are compressed and loaded progressively. |
| Offline | Educators can view today's sessions and their children's information and mark attendance without internet; data syncs automatically when the connection returns. |
| Security | Phone login with one-time codes, role-based access checked on the server, encryption in transit and at rest, private media storage with expiring links, and protection against repeated login attempts. |
| Reliability | Target availability of 99.5%, daily backups with regularly tested restores, and crash and error monitoring. |
| Capacity | Sized for RAEED's current numbers (to confirm, see Q2), with room to grow to several branches. |
| Accessibility | Respects the phone's text size settings, uses sufficient color contrast, and supports screen readers for the main screens. |
| Administration | Executives manage seasons, categories, groups, templates, and settings without needing a developer. |
| App store compliance | Privacy policy, store data-safety forms, account deletion requests, and demo accounts for store reviewers. |

## 11. Privacy, safeguarding, and compliance

**Legal framework.** The platform processes personal data about minors, including health information and photos. In Morocco, this falls under Law 09-08 on the protection of personal data, supervised by the CNDP. A reform of this law, to bring it closer to the European GDPR, has been under discussion for several years, so check whether a new text has been adopted before launch. Before going live, RAEED should declare the processing to the CNDP (health data may require prior authorization), confirm the conditions for hosting data outside Morocco, which counts as a cross-border transfer, and have the privacy policy, consent texts, and retention periods reviewed by a legal advisor. This document is not legal advice.

**Consent.** Guardians consent to data processing and choose an image-rights level for each child. Consents are dated and versioned, can be changed at any time, and take effect immediately.

**Minimal data.** Collect only what is needed to care for the child. Health information is limited to what educators need for safety, and every access to it is logged.

**Safeguarding rules.** There is no private channel between an educator and a child. Executives can read conversations between educators and families, and every user is told this. Educators cannot export lists. An educator's access ends the moment they leave. All staff accept a code of conduct in the app before their first use, and any user can report a message or a post.

**Media protection.** Photos and videos are stored privately and are never reachable through public links. There is no "share outside the app" button. Optionally, screenshots of the Memories Wall can be blocked on Android and detected on iOS.

**Data retention (proposal, to be validated by a legal advisor).**

| Data | Proposed retention |
|---|---|
| Child and family records | While enrolled, then 2 years, then deleted or anonymized |
| Health information | Deleted when the child leaves the association |
| Memories Wall albums | Archived by season and deleted after 3 seasons (families can download their memory book first) |
| Conversations | 2 years after the end of the season |
| Audit logs | 3 years |

## 12. Recommended technical approach

| Layer | Recommendation | Why |
|---|---|---|
| Mobile apps | Flutter, with one codebase for iOS and Android | Strong Arabic and right-to-left support; one team builds both apps |
| Executive dashboard | A web application (Flutter Web or React) | Large screens suit data entry, imports, and statistics |
| Backend | A managed backend such as Supabase (PostgreSQL database, authentication, file storage, row-level security), or Firebase | The data is relational (children, groups, educators) and reporting-heavy; row-level security enforces role permissions inside the database itself |
| Push notifications | Firebase Cloud Messaging | The standard for both Android and iOS |
| Login codes and invitations | An SMS provider with good coverage in Morocco, plus WhatsApp where possible | Parents rely on phone numbers and WhatsApp every day |
| Media | Private storage with expiring links, and compression on the phone before upload | Protects children's photos and controls costs |
| Hosting region | Chosen after the CNDP check (§11) | Compliance |
| Monitoring | Crash and error reporting, with no advertising or tracking SDKs | Quality and privacy |

**Ownership.** The association, not the developer, must own the Apple and Google developer accounts, the cloud accounts, the domain name, and the source code repository. Registering as an organization on the app stores requires a D-U-N-S number, which can take time to obtain, so start early.

**App review.** Because accounts are invitation-only, prepare demo accounts (parent, educator, executive) for the Apple and Google reviewers.

## 13. Roadmap

| Step | Content | Done when |
|---|---|---|
| 0. Discovery and design | Validate this document with the board, 3–5 parents, and 3–5 educators; wireframes and a clickable prototype; CNDP and legal check | Scope and designs are approved |
| 1. MVP development | All Must requirements of the MVP, then Should items as time allows | All Must items are delivered and tested |
| 2. Pilot | 2–3 groups for 4–6 weeks, with weekly feedback and fixes | 80% of pilot families are active, and attendance is recorded for 95% of sessions |
| 3. Full launch | All groups, onboarding days for parents at the association, and educator training | Official communication has moved to the app |
| 4. V1 | Events and camps, enrollment and fees, homework submissions, pick-up persons, repeated-absence alerts, memory book | V1 items are delivered and adopted |

## 14. Risks and mitigations

| Risk | Mitigation |
|---|---|
| Parents don't adopt the app | Invitations by SMS and WhatsApp, a help desk during onboarding days, a simple Arabic-first design, and value from day one (attendance, photos, announcements) |
| WhatsApp groups continue in parallel | Announce a date after which official communication happens only in the app |
| Educators see the app as extra work | One-minute attendance, recurring sessions, templates, training, and availability hours |
| A photo or data leak | Consent enforcement, private storage, no external sharing, audit logs, and a code of conduct |
| Storage and SMS costs grow | Compression, video limits, in-app and WhatsApp messages before SMS, and a monthly cost review |
| Scope creep delays the launch | Only Must items block the MVP; every new idea goes to the backlog for V1 or later |
| Dependence on a single developer | Standard technologies, documentation, and the association owning all accounts and code |

## 15. Open questions for the board

| # | Question | Why it matters | Suggested default |
|---|---|---|---|
| Q1 | What is the age range and gender of each of the 8 categories, and are educators assigned by gender? | Group setup, educator assignment, Memories Wall visibility, and statistics | To be provided (see the table in §5.2) |
| Q2 | How many children, groups, educators, and branches are there today, and in three years? | Sizing and running costs | To be provided |
| Q3 | Can a child belong to several groups at the same time (e.g., a main group and a Quran circle)? | Data model and parent views | Yes, with one main group |
| Q4 | Who can publish on the Memories Wall without approval? | Moderation workload | Educators publish directly; executives moderate afterwards |
| Q5 | Can parents comment on posts, or only react? | Moderation and privacy | Reactions only |
| Q6 | Do executives read conversations at any time, or only after a report? | Balance between trust and safeguarding | Read access at any time, logged and disclosed |
| Q7 | What are the educators' availability hours for messages? | Volunteers' wellbeing | 9:00–20:00 |
| Q8 | Are there fees today, and how are they collected? | Scope of the V1 fees module | To be provided |
| Q9 | What is the default language of the app? | Design and content | Arabic, with French and English available |
| Q10 | Who will build the app (volunteer, freelancer, or agency), and with what budget? | Technology choices and timeline | To be decided |
| Q11 | Which retention periods does the board approve (§11)? | Legal compliance | The proposal in §11 |

## 16. Glossary

| Term | Meaning |
|---|---|
| Mo'atir (مؤطر) | Educator who leads a group's activities |
| Moshrif (مشرف) | Executive: a member of the management team with oversight of everything |
| Guardian | A parent or legal guardian linked to a child |
| Season | A school-year cycle, such as 2026–2027 |
| Category (فئة) | An age level containing one or more groups; RAEED has 8, such as الأشبال and الزهرات |
| Group | Children following the same program with the same educators |
| Session | One scheduled activity of a group |
| Presence confirmation | The question sent to parents before a session to know whether the child will attend |
| Attendance | What actually happened at the session: present, absent, late, or excused |
| Memories Wall | The private space for photos, videos, and banners from activities (originally "memorial wall") |
| Announcement | Official information sent to a chosen audience |

## Appendix A. Where each original feature lives

| Original feature | Requirements |
|---|---|
| Three roles: parents, educators, executives | ACC-01 |
| Parents access their children's information (number of children, group, attendance, schedules) | CHD-01, CHD-05, SES-07 |
| Parents see assigned homework | HWK-02 |
| Parents access session files and videos for later learning | MAT-01, MAT-02 |
| Parents chat with educators | MSG-01 |
| Parents' wall of photos, videos, and banners | WAL-01, WAL-02 |
| Educators access all their groups (many-to-many) | ORG-03 |
| Educators see their children's information (name, age, allergies, parents) | CHD-02, CHD-03 |
| Educators mark attendance | ATT-06 |
| Educators plan weekly sessions and upload materials | SES-01, SES-03 |
| Educators send a presence question to parents | ATT-01 |
| Educators give homework | HWK-01 |
| Educators chat with parents | MSG-01 |
| Educators share on the wall | WAL-01 |
| Executives access everything, at least through logs | AUD-01, AUD-02 |
| Executive dashboard with statistics | DSH-01, DSH-02 |
| Executive announcements on home pages and as notifications | ANN-01 |
| Executives communicate with parents and educators | MSG-02 |
