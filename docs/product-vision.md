Here's a comprehensive prompt you can use with Claude, Emergent, or another AI coding assistant. It gives enough detail for the AI to design an enterprise-grade application that integrates with your existing ERP.

---

# Prompt

**Act as a Senior Enterprise Software Architect, Product Manager, UI/UX Designer, and Full-Stack Developer.**

I own **Marbiks Professional**, a premium beauty, skin, hair, wellness, academy, and cosmetics company based in India.

I already have an existing ERP system that manages customers, billing, appointments, inventory, employees, attendance, products, reports, and accounting. The new application **must integrate with the existing ERP** rather than replacing it.

The application should be scalable to **500+ branches** and **10,000+ daily users**.

---

## Primary Objective

Build a modern, AI-enabled business management application that synchronizes with the existing ERP through APIs or database integration.

The application should work on:

* Android
* iOS
* Web
* Tablet
* Desktop

Use a responsive interface.

---

# User Roles

Create separate dashboards for:

* Super Admin
* Director
* General Manager
* HR Manager
* Branch Manager
* Floor Manager
* Receptionist
* Technician
* Store Manager
* Accountant
* Marketing Manager
* Digital Marketing Team
* Trainer
* Academy Student
* Franchise Owner
* Customer

Each role must have different permissions.

---

# ERP Integration

The app must connect with the existing ERP and synchronize:

Customers

Appointments

Invoices

Products

Inventory

Stock

Employees

Attendance

Leaves

Salary

Incentives

Memberships

Packages

Reports

Expenses

Accounts

GST

Vendors

Purchase Orders

Branches

Service Menu

Machines

Loyalty Points

Feedback

Notifications

Sync should work:

Real Time

Scheduled

Manual Sync

Offline Queue

Conflict Resolution

---

# Customer Features

Customer Registration

OTP Login

Google Login

Apple Login

Booking

Rescheduling

Cancellation

Membership

Wallet

Packages

Offers

Gift Cards

Service History

Before/After Photos

Loyalty Points

Digital Invoice

Reviews

Chat Support

Video Consultation

Online Payment

Home Service Booking

Notifications

Referral Program

Subscription Plans

---

# Appointment Management

Smart Calendar

Drag & Drop

Chair Allocation

Room Allocation

Bed Allocation

Technician Allocation

Machine Allocation

Auto Conflict Detection

AI Scheduling

Waitlist

No-show Management

---

# AI Features

Integrate AI throughout the application.

Examples:

AI Receptionist

AI Appointment Scheduler

AI Customer Support

AI Product Recommendation

AI Skin Analysis

AI Hair Analysis

AI Membership Recommendation

AI Offer Recommendation

AI Revenue Prediction

AI Sales Forecast

AI Staff Performance Prediction

AI Inventory Prediction

AI Reorder Suggestions

AI Customer Churn Prediction

AI Marketing Campaign Suggestions

AI WhatsApp Replies

AI Voice Assistant

AI Dashboard Summary

AI Business Insights

---

# Technician App

Daily Targets

Attendance

Clock In/Out

Service Queue

Customer Notes

Treatment History

Before/After Images

Product Recommendation

Commission Calculator

Performance Dashboard

Training Videos

Task Checklist

Leave Request

Salary Slip

Notifications

---

# HR Module

Recruitment

Interview Tracking

Offer Letters

Joining

Attendance

Leave

Payroll

ESI

PF

Training

Performance Review

Warning Letters

Promotion

Transfer

Exit Management

---

# Inventory Module

Barcode

QR Code

Warehouse

Branch Transfer

Low Stock Alert

Expiry Alert

Batch Tracking

Purchase Order

Vendor Management

Stock Audit

Consumption Tracking

Cosmetic Manufacturing Stock

---

# Marketing Module

Campaign Management

Facebook Integration

Instagram Integration

Google Ads Integration

WhatsApp Marketing

Bulk SMS

Email Marketing

Push Notifications

Coupons

Referral Campaign

Festival Campaign

Lead Management

CRM

---

# Finance Module

Income

Expense

Profit & Loss

Cash Flow

GST Reports

Bank Reconciliation

Outstanding

Vendor Payments

Branch Profitability

Loan Tracking

Budget

Forecast

---

# Academy Module

Admissions

Courses

Attendance

Assignments

Online Classes

Certificates

Fees

Examinations

Placements

Student Portal

Trainer Portal

---

# Franchise Module

Franchise Dashboard

Royalty Calculation

Sales Tracking

Branch Comparison

Audit Checklist

Training

Support Tickets

Inventory Monitoring

Compliance

---

# Reports

Real-time Dashboard

Branch Dashboard

Company Dashboard

Revenue

Customer Analytics

Employee Analytics

Inventory Analytics

Marketing Analytics

Finance Analytics

Product Sales

Service Sales

Machine Utilization

Chair Utilization

Daily Reports

Weekly Reports

Monthly Reports

Yearly Reports

---

# Security

JWT Authentication

Role Based Access

Multi-factor Authentication

Audit Logs

Encryption

Backup

Cloud Sync

Disaster Recovery

GDPR Ready

Data Privacy

---

# Technology Stack

Suggest the best modern architecture.

Preferred:

Frontend

Flutter

or

React Native

Backend

Node.js

NestJS

or

.NET Core

Database

PostgreSQL

Redis

MongoDB (optional)

Cloud

AWS

Azure

Google Cloud

Docker

Kubernetes

API

REST

GraphQL

WebSocket

---

# UI Design

Premium luxury appearance

Apple-like interface

Minimal

Modern

Fast

Dark Mode

Light Mode

Animations

Beautiful dashboards

Large touch controls

Accessible

Responsive

---

# Performance

Load under 2 seconds

Support 10,000 or more concurrent users

Offline Mode

Caching

Real-time Sync

Scalable Microservices

---

# Deliverables

Generate:

1. Complete Software Requirement Specification (SRS)

2. Complete System Architecture

3. Database ER Diagram

4. API Documentation

5. User Flow

6. Wireframes

7. UI Screens

8. Folder Structure

9. Backend Architecture

10. Frontend Architecture

11. Database Schema

12. API Endpoints

13. Authentication Flow

14. ERP Integration Strategy

15. AI Integration Plan

16. Deployment Plan

17. CI/CD Pipeline

18. Security Architecture

19. Testing Strategy

20. Production Roadmap

21. MVP Plan

22. Phase-wise Development Plan

23. Estimated Timeline

24. Estimated Team Structure

25. Future Scalability Plan

---

# Important Requirement

The application **must not duplicate ERP business logic**. It should act as a smart digital layer over the ERP by consuming its APIs (or securely integrating with the ERP database if APIs are unavailable). Use an **API-first approach** with an abstraction layer so the ERP can be replaced in the future without rewriting the mobile or web apps.

Design the system with a **plugin architecture**, allowing future modules such as telemedicine, e-commerce, AI agents, IoT devices, facial recognition attendance, biometric devices, WhatsApp Business API, payment gateways, and third-party integrations to be added without major code changes.

The codebase should follow **Clean Architecture**, **SOLID principles**, **Domain-Driven Design (DDD)**, and include comprehensive documentation, automated tests, logging, monitoring, and production-ready deployment configurations.

---
