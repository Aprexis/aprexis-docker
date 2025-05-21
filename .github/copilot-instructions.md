# Aprexis

## Project Overview
Aprexis Docker is an umbrella project for a group of separate code repositories that underpin different applications in the Aprxis ecosystem. These repositories are checked out individually into subdirectories of this project's root dir.

The subdirectories are
- **aprexis-platform-5** - A Ruby On Rails web application with Postgres and Redis data stores.
- **aprexis-etl** - A Ruby application that is used to import data from Aprexis customers into the Postgres database.
- **aprexis-api** - A Ruby on RAils web application that provide a web-based JSON API to the same active_record models as the aprexis-platform-5 application
- **aprexis-engine** - A Ruby Gem that provides the active_record model classes used by the aprexis-platform-5 and aprexis-etl applications
- **aprexis-api-ui** - Node web application that provides an admin level UI to the database via the API provided by aprexis-api

## Business Context
Aprexis is a platform for pharmacists to perfom Medication Therapy Management (MTM) for patients that have complex medication regimens. Pharmacist users login to the aprexis-platform-5 applcation an perform work on improving patients' medication usage. Aprexis operates in the HIPAA regulated healthcare industry.

### Core Features
- The system receives pharmacy claims and medical claim data from health plans on an ongoing basis.
- The system searches the data for patients that are most likely to benefit from having their medications reviewed.
- Pharmacist users login to the aprexis-platform-5 application to review and make recomendations to patients' medication usage.
- Pharmacists recommendations are output a PDFs. These PDFs can optionally be faxed to the patients' healthcare providers.
- Pharmacists can optionally meet with Patients virtually, using an in-app video chat.

## Architecture Guidelines
- This is a multi-tenant application where each tenant is a health plan
- Maintain clear separation of concerns between tenant data
- Follow existing naming conventions and code style
- Use the established Rails patterns in the codebase
- Consider data privacy and security in all feature implementations

## Development Practices
- Do not refactor code unless explicitly instructed
- Follow test-driven development for new features
- New UI components should follow existing design patterns
- Be mindful of database performance with tenant-specific queries
- Document any API changes or new integrations

## Key Business Concepts
- Pharmacist: Users who manage the platform to serve their clients
- Patient: People who generally have complex medication usage, usuall due to chronic health conditions
- PatientSearchAlgorithm: the mechanism for finding patients who may benefit
- Intervention: The unit of work where a pharmacist reviews a specific patient's medication usage and offers recommendations for improvements to that usage.
- Program: The type of recommendations that a pharmacist will be looking to provide to patients. There are two types of Programs:
    1) Comprehensive Medication Reviews (CMR), where the pharmacist is reviewing a set of medications that the patient is taking. Usually the set of medications are related to specific chronic health conditions, such as asthma, copd, or heart disease.
    2) Transactional, where the pharmacist is focused on one specific medication, looking at the dosage, patient adherence, cost of that medication.

- PharmacyStore: Interventions are assigned to a specific pharmacy store, so a pharmacy store has a queue of interventions that can be worked on. Pharmacists can work at one or more pharmacy stores.
- Pharmacy: A business group of multiple pharmacy stores.


---
description:
globs: *.rb,Gemfile,*.rake
alwaysApply: false
---
# Ruby on Rails Guidelines for Aprexis

- You are an expert senior ruby on rails engineer with years of experience.

## Framework & Environment
- Ruby 3.0.3
- Rails 6.0.4.8
- PostgreSQL database
- Redis for background job processing
- Puma as application server

## Key Gems & Libraries
- **Authentication**: Devise
- **Frontend**: ERB, Jquery, Jbuilder, Coffee
- **Background Processing**: Resque
- **PDF Generation**: Grover
- **Sending faxes**: Phaxio
- **Video Chat**: Twilio
- **Error Tracking**: Honeybadger
- **Model Versioning**: Audited
- **Testing**: RSpec, Factory Bot, Capybara, Cucumber

## Rails Architecture Patterns
- Follow standard Rails MVC architecture
- Use concerns for shared functionality
- Implement service objects for complex business logic
- Follow RESTful controller patterns

## Authentication & Authorization
- Use Devise for user authentication
- Never bypass authorization checks
- Follow existing authentication controller patterns

## Database Conventions
- Follow Rails naming conventions for tables and columns
- Use foreign keys for referential integrity
- Create indexes for frequently queried columns
- Use database constraints where appropriate
- Consider performance for tenant-spanning queries
- Use migrations for schema changes
- Use `audited` for tracking model changes

## Testing Guidelines
- Write tests with RSpec for all models and controllers
- Use Factory Bot for test data creation
- Follow existing patterns for tenant context in tests
- Test tenant isolation explicitly
- Use mocks for external services (Phaxio, Twilio)
- Integration tests with Cypress for critical user flows

## Background Processing
- Use Resque for background processing
- Follow existing job class patterns
- Consider job priority for time-sensitive operations
- Implement proper error handling

