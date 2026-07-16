# Bloom IVF backend contract

The Flutter app must talk only to an HTTPS backend. The backend owns the MongoDB connection string and is responsible for authentication, permissions, validation, and database writes.

## App configuration

Run the app with the API URL only—never with a MongoDB URI:

```powershell
flutter run --dart-define=API_BASE_URL=https://api.your-domain.com
```

The app reads this value from `lib/services/backend_config.dart`.

## Authentication

| Method | Endpoint | Request | Response |
| --- | --- | --- | --- |
| POST | `/v1/auth/register` | `{ name, email, password }` | `{ accessToken, patient }` |
| POST | `/v1/auth/login` | `{ email, password }` | `{ accessToken, patient }` |
| POST | `/v1/auth/logout` | none | `204` |
| GET | `/v1/patients/me` | Bearer token | `{ patient }` |
| PUT | `/v1/patients/me` | patient profile fields | `{ patient }` |

Passwords must be hashed in the backend (bcrypt or Argon2). Never store passwords in a patient document or in SharedPreferences.

## Patient data endpoints

All endpoints below require `Authorization: Bearer <accessToken>` and must only return records belonging to the signed-in patient.

| Data area | Endpoints |
| --- | --- |
| Appointments | `GET /v1/appointments`, `POST /v1/appointments`, `PATCH /v1/appointments/:id`, `DELETE /v1/appointments/:id` |
| Treatment journey | `GET /v1/treatment-plan`, `PATCH /v1/treatment-plan/:stageId` |
| Medication schedule | `GET /v1/medications`, `POST /v1/medications`, `PATCH /v1/medications/:id` |
| Daily symptom check-ins | `GET /v1/check-ins`, `POST /v1/check-ins` |
| Cycle tracker | `GET /v1/cycle-entries`, `POST /v1/cycle-entries` |
| Hydration log | `GET /v1/hydration?date=YYYY-MM-DD`, `PUT /v1/hydration/:date` |
| Visit checklist | `GET /v1/checklists/visit`, `PUT /v1/checklists/visit` |
| Saved / liked library items | `GET /v1/library/preferences`, `PUT /v1/library/preferences` |

## MongoDB collections

Use collections such as `patients`, `appointments`, `treatmentPlans`, `medications`, `dailyCheckIns`, `cycleEntries`, `hydrationLogs`, `checklists`, and `libraryPreferences`. Every patient-owned document needs a `patientId` ObjectId and backend authorization must scope queries to that ID.

## Before connecting

1. Rotate the database password that was exposed in the shared screenshot.
2. Restrict MongoDB Atlas network access to the backend server, not mobile clients.
3. Create a least-privilege database user for the backend.
4. Use HTTPS, short-lived JWT access tokens, input validation, rate limits, and audit logs.
