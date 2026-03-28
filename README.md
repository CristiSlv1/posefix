🏋️ PoseFix

Design and Implementation of an AI-Based Mobile Application for Automatic Gym Exercise Posture Analysis and Feedback

1. Project Overview

PoseFix is an AI-powered mobile application that analyzes gym exercise posture using computer vision and provides structured corrective feedback.

The system enables users to record themselves performing exercises and receive:

Posture correctness score (0–100)

Detected mistakes

Joint angle evaluations

Improvement suggestions

The goal is to simulate basic personal trainer feedback using lightweight pose estimation (MediaPipe) and rule-based posture evaluation logic.

2. Problem Statement

Incorrect execution of gym exercises is a major cause of injuries among amateur athletes.

Most individuals:

Train without supervision

Use incorrect range of motion

Misalign joints

Compensate using wrong muscles

Professional trainers are:

Not always accessible

Expensive

Not scalable

PoseFix aims to provide:

Accessible

Affordable

Intelligent

Real-time or near-real-time feedback

3. System Architecture
High-Level Architecture

Flutter Mobile App
⬇
Java Spring Boot Backend
⬇
Supabase (PostgreSQL + Auth)
⬇
Python ML Service (MediaPipe + custom posture rules)

Technology Stack
Mobile

Flutter

Supabase Auth SDK

Backend

Java 17

Spring Boot 3.x

Spring Security

Spring Data JPA

PostgreSQL (Supabase)

Machine Learning

Python

MediaPipe BlazePose

Custom angle evaluation algorithms

Database

Supabase PostgreSQL

RLS enabled

Structured relational schema

4. Core Features (MVP Scope)
4.1 Authentication

User registration via Supabase Auth

JWT-based authentication

Backend validates token before any data operation

4.2 User Profile

User can:

Store name

Birth date

Height (cm)

Weight (kg)

Sex

Age is computed dynamically from birth date.

4.3 Weight Tracking

One weight entry per day

Long-term progress visualization

No multiple daily entries (to avoid psychological distortion)

Backend enforces uniqueness per day

4.4 Workout Logging

User can:

Select exercise (e.g., lat pulldown)

Add sets

Add reps

Add weight

Add notes

Workouts are tied to authenticated user ID.

4.5 Exercise Library

Exercises stored in DB:

name

code

category

muscle group

description

Initially:

Lat pulldown
Later expandable.

4.6 Posture Analysis

User flow:

User records a video locally.

Video is uploaded to backend.

Backend forwards video to ML service.

ML service:

Extracts body landmarks (MediaPipe)

Computes joint angles

Applies rule-based posture evaluation

ML returns:

Score (0–100)

Mistake list

Angle summary

Backend:

Stores analysis in DB

Returns result to mobile

Video is deleted after processing.

No long-term video storage in MVP.

5. User Journey
Step 1 — Registration

User signs up via Supabase Auth.

Step 2 — Profile Setup

User enters:

Name

Height

Weight

Birth date

Sex

Step 3 — Add Workout

User:

Selects exercise

Inputs sets, reps, weight

Step 4 — Record Exercise

User records video performing exercise.

Step 5 — Analyze

User uploads video.

System:

Processes video

Detects posture

Calculates score

Shows structured feedback

Step 6 — Track Progress

User can:

View past workouts

View weight trend

Compare posture scores

6. Backend Responsibilities

The backend is responsible for:

Validating Supabase JWT tokens

Enforcing user ownership of data

Managing relational data (profiles, workouts, weights)

Forwarding video to ML service

Storing posture analysis results

Returning structured JSON responses

Backend does NOT:

Store videos permanently

Perform heavy ML computation

Handle frontend UI logic

7. Database Model Overview

Tables:

profiles

weight_history

exercises

workouts

posture_analyses

Relationships:

auth.users (Supabase)
↓
profiles (1–1)
↓
workouts (1–N)
↓
posture_analyses (1–1 per workout)

Weight history is independent but user-owned.

8. ML Processing Workflow

Video → Frame Extraction → Pose Detection → Angle Calculation → Rule Evaluation → Score Computation → Structured Output

Angle examples:

Elbow flexion

Shoulder abduction

Back alignment

Hip angle

Each rule:

Defines acceptable angle range

Detects violation

Adds mistake description

Score calculation:

Based on rule violations

Weighted penalties

Normalized to 0–100

9. Security Model

Supabase handles authentication.

Backend validates JWT via Supabase /auth/v1/user.

All user data queries filtered by authenticated user ID.

RLS enabled in Supabase.

Service role key never exposed to client.

10. Non-Functional Requirements

Lightweight processing

No permanent video storage

Scalable exercise support

Clean API architecture

Clear separation of concerns

Extensible posture rule engine

11. Future Extensions

Real-time pose correction

Multiple camera angle support

AI-based adaptive feedback

Personalized training recommendations

Exercise recommendation system

Cloud storage optimization

Leaderboard or gamification

Performance analytics dashboard

12. Development Roadmap Summary

Phase 1 — Backend core + auth
Phase 2 — Profiles + weight tracking
Phase 3 — Workout system
Phase 4 — Posture analysis stub
Phase 5 — ML integration
Phase 6 — Flutter UI
Phase 7 — Optimization + testing

13. MVP Definition

The MVP is complete when:

User can authenticate

User can log workout

User can upload exercise video

System returns posture score + mistake list

Results are stored

No video remains stored after analysis