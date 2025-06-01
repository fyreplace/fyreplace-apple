import SwiftUI

struct EmailsScreen: View, EmailsScreenProtocol {
    @EnvironmentObject
    var eventBus: EventBus

    @Environment(\.api)
    var api: any APIProtocol

    @State
    var isLoading = false

    @State
    var showAddEmail = false

    @State
    var showVerifyEmail = false

    @State
    var emails: [Components.Schemas.Email] = []

    @State
    var newEmail = ""

    @State
    var unverifiedEmail = ""

    @State
    var randomCode = ""

    var body: some View {
        DynamicList {
            Section {
                ForEach(emails) { email in
                    let verify = { () in
                        unverifiedEmail = email.email
                        showVerifyEmail = true
                    }

                    LabeledContent {
                        #if os(macOS)
                            if email.main {
                                Label("Emails.Main", systemImage: "star.fill")
                            } else if !email.verified {
                                Button("Emails.Verify", action: verify)
                            }
                        #endif
                    } label: {
                        Text(verbatim: email.email)

                        #if !os(macOS)
                            if email.main {
                                Text("Emails.Main")
                            } else if !email.verified {
                                Button(action: verify) {
                                    HStack {
                                        Image(systemName: "exclamationmark.triangle")
                                        Text("Emails.Verify")
                                    }
                                }
                            }
                        #endif
                    }
                    .frame(minHeight: 30)
                }
            } footer: {
                let unverifiedCount = emails.count(where: { !$0.verified })

                if unverifiedCount > 0 {
                    VStack {
                        Text("Emails.Help.RandomCode:\(unverifiedCount)")
                    }
                }
            }
        }
        .navigationTitle(Destination.emails.titleKey)
        .toolbar {
            ToolbarItem {
                if isLoading {
                    ProgressView()
                        #if os(macOS)
                            .controlSize(.small)
                        #endif
                } else {
                    Button {
                        showAddEmail = true
                    } label: {
                        Image(systemName: "plus").help("Emails.Add")
                    }
                }
            }
        }
        .alert("Emails.Add", isPresented: $showAddEmail) {
            Button("Cancel", role: .cancel) {}

            Button("Ok") {
                Task {
                    await addEmail()
                }
            }
            .disabled(newEmail.isEmpty)

            TextField("Emails.Add.Prompt", text: $newEmail)
                .textContentType(.email)
                #if !os(macOS)
                    .keyboardType(.emailAddress)
                #endif
        }
        .alert("Account.RandomCode", isPresented: $showVerifyEmail) {
            Button("Cancel", role: .cancel) {}

            Button("Ok", action: verifyEmail)
                .disabled(randomCode.isEmpty)

            TextField("Account.RandomCode.Prompt", text: $randomCode)
                .textContentType(.oneTimeCode)
                #if !os(macOS)
                    .keyboardType(.asciiCapable)
                #endif
        }
        .onAppear {
            Task {
                await loadEmails()
            }
        }
        .onReceive(eventBus.events) {
            if case let .emailVerified(email) = $0 {
                finishVerifyingEmail(email)
            }
        }
        .handlesExternalEvents(preferring: ["*"], allowing: ["action=email"])
    }
}

#Preview {
    NavigationStack {
        EmailsScreen()
    }
}
