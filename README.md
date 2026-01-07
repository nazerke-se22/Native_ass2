""Student Management — Swift (Console Application)""
Overview
This project is a console-based Student Management application implemented in Swift as part of the Native Mobile Development – Combined Assignment (Weeks 4–5).
The goal of the project is to demonstrate Object-Oriented Programming, functions, and closures in Swift, following all assignment requirements.
The application allows managing students and courses with full CRUD functionality and basic validation.
Features
Student Management (CRUD)
Add a student
Edit a student
List all students
Delete a student
Course Management (CRUD)
Add a course
Edit a course
List all courses
Delete a course
Additional Functionality
Filter students by GPA (using closures)
Sort students by GPA (descending)
Calculate average GPA
Input validation and error handling
Data Model & OOP Design
Entities
Student — implemented as a struct
Properties: id, name, gpa, courseId
Course — implemented as a class
Properties: id, title
Protocol
Validatable
Used by Student to validate input data (ID, name, GPA)
Architecture
Manager class encapsulates all business logic and storage
Models are separated from user interaction logic
Data is stored in memory using arrays
This design demonstrates:
Encapsulation
Separation of concerns
Proper use of struct, class, and protocol in Swift
Functions and Closures
Reusable Functions
The project includes multiple non-trivial functions, such as:
Adding, editing, deleting students and courses
Validating student data
Calculating average GPA
Sorting and filtering students
Closures Usage
Closures are used in multiple places:
Filtering students by GPA
Sorting students by GPA
Higher-order function that accepts a closure as a parameter
This fulfills the requirement for using closures meaningfully.
Error Handling & Edge Cases
The application handles common edge cases:
Empty input values
Invalid GPA values
Duplicate student or course IDs
Editing or deleting non-existing entities
Empty student or course lists
Errors are displayed clearly in the console.
Assumptions
GPA values are in the range 0.0 – 4.0
Course assignment to a student is optional
Data is not persisted between runs (in-memory storage only)
Defense Preparation Notes
During defense, the following topics can be explained:
Why Student is a struct and Course is a class
How protocols are used for validation
Where and why closures are applied
How CRUD operations and error handling are implemented
Conclusion
This project meets all assignment requirements, demonstrates core Swift concepts, and maintains a clean and beginner-friendly structure while remaining fully functional.
