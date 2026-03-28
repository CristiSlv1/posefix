Phase 0 — Repo + hygiene

 Repo structure (backend/ mobile/ ml-service/ docs/)

 Spring Boot app runs (/health)

 DB connectivity (/exercises)

 Supabase token validation (/me)

 Workouts create/list

Next: lock engineering hygiene

Add .env.example (no secrets) + .gitignore

Add basic logging + error handler (global)

Add README “how to run backend locally”

Phase 1 — Authentication & API security (must do early)

Right now auth is “manual per controller”. Make it reusable.

1.1 Centralize auth extraction

Implement one of these:

Option A (best): OncePerRequestFilter that:

reads Authorization: Bearer

calls Supabase /auth/v1/user

stores userId in request context

Option B: AuthService + ControllerAdvice helper (simpler)

Outcome:

Controllers don’t parse tokens manually anymore

1.2 Lock down Spring Security

permitAll: /health, /exercises

authenticated: everything else

Disable form login

Add CORS (you already did permissive; later restrict)

Phase 2 — Core domain endpoints (MVP backend)

These are the endpoints your Flutter app will need.

2.1 Profiles

Endpoints:

GET /profile (returns current user profile)

PUT /profile (update name, height, weight, birthdate)

Optional but great:

auto-create profile on first login (if missing)

2.2 Weight history (1 per day)

Endpoints:

GET /weights (list last N entries)

PUT /weights/today (upsert today’s weight)

if exists -> update

if not -> insert

also update profiles.weight_kg

2.3 Workouts (you started)

Complete it:

POST /workouts

GET /workouts

GET /workouts/{id}

DELETE /workouts/{id} (optional)

PUT /workouts/{id} (optional)

Also add validation:

exercise exists

sets/reps non-negative, etc.

Phase 3 — Posture analysis API (stub → real)

This is the thesis core, so do it in two steps.

3.1 Stub analysis (fast)

Add:

POST /workouts/{id}/analyze
Returns dummy:

score 85

mistakes []

angles_summary {}

And inserts a posture_analyses row.

This lets Flutter UI be built early.

3.2 Real analysis (call Python service)

Backend calls Python ML microservice:

send local file reference? (probably no)

send frames or uploaded video? (likely yes, via multipart)

receive result JSON (mistakes, angles_summary, score)

Then:

store into posture_analyses

return to client

Phase 4 — File upload strategy (important design choice)

Even if video stays local long-term, you still need an approach:

Option A (simplest MVP)

Flutter uploads video to backend for analysis (multipart/form-data)
Backend streams to Python, then discards.

Option B (more efficient later)

Flutter extracts frames (e.g., every 5th frame) and sends only frames.

For backend roadmap:

implement Option A first

optimize later if needed

Endpoints:

POST /workouts/{id}/upload-video (optional)
or combine with analyze endpoint.

Phase 5 — Data validation, errors, and DTO cleanup

Use DTOs everywhere (don’t expose entities directly)

Add @ControllerAdvice to standardize errors:

400 validation errors

401 unauthorized

404 not found

500 internal

Phase 6 — Observability & testing (thesis-friendly)
6.1 Tests

Unit tests for:

angle rule evaluation (later in Python, but backend has validations)

repositories (integration tests)

API tests:

Postman collection or simple JUnit + Testcontainers (optional)

6.2 Logging

Request ID

Log analyze processing time

Store processing_ms in DB

Phase 7 — Deployment (only after it works locally)

Dockerize backend

Add docker-compose for local dev:

backend

ml-service

For thesis: you can keep it local, but docker screenshots look professional

Recommended execution order (what you do next week)

Central auth filter + lock endpoints

Profile endpoints

Weight history endpoints

Analyze stub endpoint + DB insert

Integrate Python service call

That puts you in a position where Flutter becomes straightforward.