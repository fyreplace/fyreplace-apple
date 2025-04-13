import PhotosUI
import SwiftUI

@MainActor
protocol SettingsScreenProtocol: APIViewProtocol {
    var token: String { get nonmutating set }
    var currentUser: Components.Schemas.User? { get nonmutating set }
    var bio: String { get nonmutating set }
    var isLoadingAvatar: Bool { get nonmutating set }
}

@MainActor
extension SettingsScreenProtocol {
    var canUpdateBio: Bool {
        bio != currentUser?.bio ?? "" && bio.count <= Components.Schemas.User.maxBioSize
    }

    func getCurrentUser() async {
        await call {
            let response = try await api.getCurrentUser()

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .json(user):
                    currentUser = user
                    bio = user.bio
                }

                return nil

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }
    }

    func updateAvatar(with data: Data) async {
        isLoadingAvatar = true

        await call {
            let response = try await api.setCurrentUserAvatar(body: .binary(.init(data)))

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .plainText(text):
                    currentUser?.avatar = try await .init(collecting: text, upTo: 1024)
                }

                return nil

            case .contentTooLarge:
                return .failure(
                    title: "Settings.Error.ContentTooLarge.Title",
                    text: "Settings.Error.ContentTooLarge.Message"
                )

            case .unsupportedMediaType:
                return .failure(
                    title: "Settings.Error.UnsupportedMediaType.Title",
                    text: "Settings.Error.UnsupportedMediaType.Message"
                )

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }

        isLoadingAvatar = false
    }

    func removeAvatar() async {
        isLoadingAvatar = true

        await call {
            let response = try await api.deleteCurrentUserAvatar()

            switch response {
            case .noContent:
                currentUser?.avatar = ""
                return nil

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }

        isLoadingAvatar = false
    }

    func updateBio() async {
        await call {
            let response = try await api.setCurrentUserBio(
                body: .plainText(bio.isEmpty ? .init() : .init(stringLiteral: bio)))

            switch response {
            case let .ok(ok):
                switch ok.body {
                case let .plainText(text):
                    bio = try await .init(
                        collecting: text, upTo: Components.Schemas.User.maxBioSize * 4)
                    currentUser?.bio = bio
                }

                return nil

            case .badRequest:
                return .failure(
                    title: "Error.BadRequest.Title",
                    text: "Error.BadRequest.Message"
                )

            case .unauthorized:
                return .authorizationIssue

            case .forbidden, .default:
                return .error()
            }
        }
    }

    func logout() {
        token = ""
    }
}
