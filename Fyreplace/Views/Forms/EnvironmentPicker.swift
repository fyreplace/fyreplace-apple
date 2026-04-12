import SwiftUI

struct EnvironmentPicker: View {
    @AppStorage("connection.environment")
    private var selectedEnvironment = ServerEnvironment.default

    var body: some View {
        Picker("Environment.Title", selection: $selectedEnvironment) {
            #if DEBUG
                let environments = ServerEnvironment.allCases
            #else
                let environments: [ServerEnvironment] = [.main, .dev]
            #endif

            ForEach(environments) { environment in
                let suffix =
                    environment == .default
                    ? " " + .init(localized: "Environment.Default")
                    : ""

                Text(verbatim: environment.description + suffix)
                    .tag(environment)
            }
        }
        .help("Environment.Help")
    }
}
