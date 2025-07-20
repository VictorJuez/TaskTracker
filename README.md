# TaskTracker

[![CI](https://github.com/TaskTracker/TaskTracker/actions/workflows/ci.yml/badge.svg)](https://github.com/TaskTracker/TaskTracker/actions/workflows/ci.yml)
[![Snyk](https://snyk.io/test/github/TaskTracker/TaskTracker/badge.svg)](https://snyk.io/test/github/TaskTracker/TaskTracker)

## Tech Stack

- .NET 9
- C# 11
- Entity Framework Core
- SQLite
- Swagger/OpenAPI
- GitHub Actions CI

## Endpoints

| Method | Endpoint    | Description         |
| ------ | ----------- | ------------------- |
| GET    | /tasks      | Get all tasks       |
| GET    | /tasks/{id} | Get a task by ID    |
| POST   | /tasks      | Create a new task   |
| PUT    | /tasks/{id} | Update a task by ID |
| DELETE | /tasks/{id} | Delete a task by ID |

## Setup

1. `dotnet restore`
2. `dotnet build`
3. `dotnet ef database update`
4. `dotnet run --project TaskTracker`

## CI

- On push or PR, GitHub Actions will:
  - Checkout code
  - Install .NET 9 SDK
  - Run `dotnet restore`, `dotnet build`, `dotnet test`
  - Run a Snyk security scan

---

This project is scaffolded for rapid development and secure CI/CD.
