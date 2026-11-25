import GamingUI
import SwiftUI

/// Consumer module that uses the reusable UI module in an app-facing preview.
public struct GamingPreviewScreen: View {
    public init() {}

    public var body: some View {
        GamingScreen()
    }
}

#Preview("Consumer Module") {
    GamingPreviewScreen()
}
