# Outreach Queue

The only door outreach leaves through. Coach writes entries here as `needs
review`. `/review-queue`, run by hand and never by the scheduler, is the only
command that reads this file and acts on it: on your approval it stages the
message where you will actually send it from (a real Gmail draft for email, the
LinkedIn compose box for LinkedIn), then stops. Your own click always sends
it. Nothing in this repo has a tool that can.

Never delete an entry. `staged <date>`, `sent <date>` and
`killed (reason)` are all worth keeping; the history is the point.

---
