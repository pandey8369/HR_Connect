# Firestore Collection & Document Schema (HR System)

## 1. users/{userId}
- name: string
- email: string
- role: "admin" | "employee"
- createdAt: timestamp

## 2. salaries/{salaryId}
- userId: string
- month: string ("April 2025")
- amount: number
- fileUrl: string (PDF URL)
- createdAt: timestamp

## 3. policies/{policyId}
- title: string
- description: string
- publishedAt: timestamp

## 4. events/{eventId}
- title: string
- description: string
- eventDate: timestamp
- createdBy: userId

## 5. attendance/{attendanceId}
- userId: string
- date: timestamp
- status: "Present" | "Absent" | "Leave"
- markedBy: userId
