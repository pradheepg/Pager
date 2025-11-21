//
//  ViewController.swift
//  Pager
//
//  Created by Pradheep G on 21/11/25.
//

import UIKit
final class UserRepositoryTester {

    private let repo = UserRepository()
    
    func printUserDetails(_ user: User) {
        print("----- USER DETAILS -----")
        print("ID: \(user.userId?.uuidString)")
        print("Name: \(user.profileName)")
        print("Age: \(user.profileImage)")
        print("Email: \(user.email)")
        print("Password; \(user.password)")
        print(user.createDate)
        print(user.dailyReadingGoalMinutes)
        print("------------------------")
    }

    // MARK: - Create 5 Test Users
    func createTestUsers() {
        let testUsers = [
            ("alpha@test.com", "pass1", "Alpha",  Date(), 10),
            ("bravo@test.com", "pass2", "Bravo", Date(), 20),
            ("charlie@test.com", "pass3", "Charlie", Date(), 30),
            ("delta@test.com", "pass4", "Delta",  Date(), 25),
            ("echo@test.com", "pass5", "Echo",  Date(), 15)
        ]

        for data in testUsers {
            let result = repo.createUser(
                email: data.0,
                password: data.1,
                profileName: data.2,
                profileImage: nil,
                createDate: data.3,
                dailyReadingGoalMinutes: data.4
            )

            switch result {
            case .success(let user):
                print("Created: \(user.email ?? "")")
                printUserDetails(user)
            case .failure(let err):
                print("Failed: \(err)")
            }
        }
    }

    // MARK: - Edit User (name + daily goal)
    func editUser(email: String, newName: String?, newGoal: Int?) {
        guard let user = repo.fetchUser(byEmail: email) else {
            print("User not found: \(email)")
            return
        }

        if let newName = newName {
            let result = repo.updateUser(user, profileName: newName)
            switch result {
            case .success: print("Name updated for \(email)")
            case .failure(let e): print("Update failed: \(e)")
            }
        }

        if let newGoal = newGoal {
            let result = repo.updateDailyReadingGoal(for: user, minutes: newGoal)
            switch result {
            case .success: print("Goal updated for \(email)")
            case .failure(let e): print("Goal update failed: \(e)")
            }
        }
    }

    // MARK: - Change Password
    func changePassword(email: String, current: String, new: String) {
        guard let user = repo.fetchUser(byEmail: email) else {
            print("User not found: \(email)")
            return
        }

        let result = repo.updatePassword(for: user, currentPassword: current, newPassword: new)

        switch result {
        case .success:
            print("Password updated for \(email)")
        case .failure(let err):
            print("Password update failed: \(err)")
        }
    }

    // MARK: - Update Profile Image
    func updateImage(email: String, image: Data) {
        guard let user = repo.fetchUser(byEmail: email) else {
            print("User not found: \(email)")
            return
        }

        let result = repo.updateProfileImage(for: user, imageData: image)

        switch result {
        case .success:
            print("Image updated for \(email)")
        case .failure(let err):
            print("Image update failed: \(err)")
        }
    }

    // MARK: - Delete One User
    func deleteUser(email: String) {
        guard let user = repo.fetchUser(byEmail: email) else {
            print("User not found: \(email)")
            return
        }

        let result = repo.deleteUser(user)

        switch result {
        case .success:
            print("Deleted user: \(email)")
        case .failure(let err):
            print("Delete failed: \(err)")
        }
    }

    // MARK: - Delete All Test Users
    func deleteAllTestUsers() {
        let emails = [
            "alpha@test.com",
            "bravo@test.com",
            "charlie@test.com",
            "delta@test.com",
            "echo@test.com"
        ]

        for email in emails {
            deleteUser(email: email)
        }
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Its happending")
        let test = UserRepositoryTester()
        test.createTestUsers()
        test.editUser(email: "alpha@test.com", newName: "Alpha Updated", newGoal: 40)
        test.changePassword(email: "alpha@test.com", current: "pass1", new: "newpass1")
        test.deleteUser(email: "echo@test.com")
        test.deleteAllTestUsers()
    }


}

