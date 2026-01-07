import Foundation

// - Error type (Result Failure must conform to Error)

enum AppError: Error {
    case message(String)
    case messages([String])
}

// - Protocol

protocol Validatable {
    func validate() -> [String]
}

// - Models (struct + class)

struct Student: Validatable {
    let id: String
    var name: String
    var gpa: Double
    var courseId: String?

    func validate() -> [String] {
        var errors: [String] = []

        if id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append("Student ID is empty.")
        }
        if name.trimmingCharacters(in: .whitespacesAndNewlines).count < 2 {
            errors.append("Name must be at least 2 characters.")
        }
        if gpa < 0.0 || gpa > 4.0 {
            errors.append("GPA must be in range 0.0...4.0.")
        }
        return errors
    }
}

final class Course {
    let id: String
    var title: String

    init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

// - Manager (encapsulation)

final class Manager {
    private(set) var students: [Student] = []
    private(set) var courses: [Course] = []

    // - COURSE CRUD 

    func addCourse(id: String, title: String) -> Result<Void, AppError> {
        let id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !id.isEmpty else { return .failure(.message("Course ID is empty.")) }
        guard !title.isEmpty else { return .failure(.message("Course title is empty.")) }
        guard courses.contains(where: { $0.id == id }) == false else {
            return .failure(.message("Duplicate course ID '\(id)'."))
        }

        courses.append(Course(id: id, title: title))
        return .success(())
    }

    func editCourse(id: String, newTitle: String) -> Result<Void, AppError> {
        guard let idx = courses.firstIndex(where: { $0.id == id }) else {
            return .failure(.message("Course '\(id)' not found."))
        }
        let clean = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return .failure(.message("New title is empty.")) }

        courses[idx].title = clean
        return .success(())
    }

    func deleteCourse(id: String) -> Result<Void, AppError> {
        guard let idx = courses.firstIndex(where: { $0.id == id }) else {
            return .failure(.message("Course '\(id)' not found."))
        }

        // If students were linked to this course, unlink them (simple behavior).
        students = students.map { s in
            var copy = s
            if copy.courseId == id { copy.courseId = nil }
            return copy
        }

        courses.remove(at: idx)
        return .success(())
    }

    // - STUDENT CRUD 

    func addStudent(_ s: Student) -> Result<Void, AppError> {
        var errors = s.validate()

        if students.contains(where: { $0.id == s.id }) {
            errors.append("Duplicate student ID '\(s.id)'.")
        }

        if let cid = s.courseId, !cid.isEmpty {
            let exists = courses.contains(where: { $0.id == cid })
            if !exists { errors.append("Unknown course ID '\(cid)'.") }
        }

        if errors.isEmpty {
            students.append(s)
            return .success(())
        } else {
            return .failure(.messages(errors))
        }
    }

    func editStudent(id: String, newName: String?, newGPA: Double?, newCourseId: String?) -> Result<Void, AppError> {
        guard let idx = students.firstIndex(where: { $0.id == id }) else {
            return .failure(.messages(["Student '\(id)' not found."]))
        }

        var updated = students[idx]
        if let newName, !newName.isEmpty { updated.name = newName }
        if let newGPA { updated.gpa = newGPA }

        // newCourseId meaning:
        // - nil => keep
        // - ""  => remove
        // - "X" => set to X
        if let newCourseId {
            updated.courseId = newCourseId.isEmpty ? nil : newCourseId
        }

        var errors = updated.validate()
        if let cid = updated.courseId {
            let exists = courses.contains(where: { $0.id == cid })
            if !exists { errors.append("Unknown course ID '\(cid)'.") }
        }

        if errors.isEmpty {
            students[idx] = updated
            return .success(())
        } else {
            return .failure(.messages(errors))
        }
    }

    func deleteStudent(id: String) -> Result<Void, AppError> {
        guard let idx = students.firstIndex(where: { $0.id == id }) else {
            return .failure(.message("Student '\(id)' not found."))
        }
        students.remove(at: idx)
        return .success(())
    }

    // - FUNCTIONS + CLOSURES 

    // Higher-order function: accepts closure parameter
    func filterStudents(_ predicate: (Student) -> Bool) -> [Student] {
        students.filter(predicate)
    }

    func sortedStudentsByGpaDesc() -> [Student] {
        students.sorted { $0.gpa > $1.gpa }
    }

    func averageGpa() -> Double? {
        guard !students.isEmpty else { return nil }
        let sum = students.reduce(0.0) { $0 + $1.gpa }
        return sum / Double(students.count)
    }

    func courseTitle(for id: String?) -> String {
        guard let id else { return "None" }
        return courses.first(where: { $0.id == id })?.title ?? "Unknown(\(id))"
    }
}

// - Console helpers

func input(_ prompt: String) -> String {
    print(prompt, terminator: "")
    return (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
}

func inputDouble(_ prompt: String) -> Double? {
    Double(input(prompt))
}

func printAppError(_ err: AppError) {
    switch err {
    case .message(let m):
        print("не знаю \(m)")
    case .messages(let ms):
        print("не знаю")
        for m in ms { print(" - \(m)") }
    }
}

func printStudent(_ s: Student, manager: Manager) {
    print("• \(s.id) | \(s.name) | GPA: \(String(format: "%.2f", s.gpa)) | Course: \(manager.courseTitle(for: s.courseId))")
}

func listStudents(_ manager: Manager, data: [Student]? = nil) {
    let arr = data ?? manager.students
    if arr.isEmpty {
        print("No students.")
        return
    }
    arr.forEach { printStudent($0, manager: manager) }
}

func listCourses(_ manager: Manager) {
    if manager.courses.isEmpty {
        print("No courses.")
        return
    }
    for c in manager.courses {
        print("• \(c.id) | \(c.title)")
    }
}

// - Main menu

let manager = Manager()

while true {
    print("""
    \n=== Student Management (Swift) ===
    Students:
      1) List students
      2) Add student
      3) Edit student
      4) Delete student
      5) Filter students (GPA >= X)
      6) Sort students by GPA (desc)
      7) Stats (average GPA)

    Courses:
      8) List courses
      9) Add course
     10) Edit course
     11) Delete course

      0) Exit
    """)

    switch input("Choose: ") {
    case "1":
        listStudents(manager)

    case "2":
        listCourses(manager)
        let id = input("Student ID: ")
        let name = input("Name: ")
        let gpa = inputDouble("GPA (0.0...4.0): ") ?? -1
        let courseId = input("Course ID (empty if none): ")

        let student = Student(id: id, name: name, gpa: gpa, courseId: courseId.isEmpty ? nil : courseId)

        switch manager.addStudent(student) {
        case .success:
            print("Student added.")
        case .failure(let err):
            printAppError(err)
        }

    case "3":
        let id = input("Student ID to edit: ")
        let name = input("New name (empty = keep): ")
        let gpaStr = input("New GPA (empty = keep): ")
        let courseId = input("New course ID (empty = remove, '-' = keep): ")

        let newName: String? = name.isEmpty ? nil : name
        let newGPA: Double? = gpaStr.isEmpty ? nil : Double(gpaStr)

        // newCourseId:
        // "-" => keep (nil)
        // ""  => remove ("")
        // "X" => set ("X")
        let newCourse: String?
        if courseId == "-" { newCourse = nil }
        else { newCourse = courseId }

        switch manager.editStudent(id: id, newName: newName, newGPA: newGPA, newCourseId: newCourse) {
        case .success:
            print("Student updated.")
        case .failure(let err):
            printAppError(err)
        }

    case "4":
        let id = input("Student ID to delete: ")
        switch manager.deleteStudent(id: id) {
        case .success:
            print("Student deleted.")
        case .failure(let err):
            printAppError(err)
        }

    case "5":
        let x = inputDouble("Show GPA >= ") ?? 0.0
        let filtered = manager.filterStudents { $0.gpa >= x }
        listStudents(manager, data: filtered)

    case "6":
        let sorted = manager.sortedStudentsByGpaDesc()
        listStudents(manager, data: sorted)

    case "7":
        if let avg = manager.averageGpa() {
            print("Average GPA: \(String(format: "%.2f", avg))")
        } else {
            print("No students -> no average.")
        }

    case "8":
        listCourses(manager)

    case "9":
        let id = input("Course ID: ")
        let title = input("Course title: ")
        switch manager.addCourse(id: id, title: title) {
        case .success:
            print("Course added.")
        case .failure(let err):
            printAppError(err)
        }

    case "10":
        let id = input("Course ID to edit: ")
        let title = input("New title: ")
        switch manager.editCourse(id: id, newTitle: title) {
        case .success:
            print("Course updated.")
        case .failure(let err):
            printAppError(err)
        }

    case "11":
        let id = input("Course ID to delete: ")
        switch manager.deleteCourse(id: id) {
        case .success:
            print("Course deleted. Linked students were unassigned.")
        case .failure(let err):
            printAppError(err)
        }

    case "0":
        exit(0)

    default:
        print("Invalid option.")
    }
}