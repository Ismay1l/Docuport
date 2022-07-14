// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let profileModel = try? newJSONDecoder().decode(ProfileModel.self, from: jsonData)

import Foundation

// MARK: - ProfileModel
struct ProfileModel: Codable {
    let firstName, lastName, fullName, emailAddress: String?
    let username, phoneNumber: String?
    let profileModelExtension: String?
    let roles: [String]?

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, fullName, emailAddress, username, phoneNumber
        case profileModelExtension = "extension"
        case roles
    }
}


