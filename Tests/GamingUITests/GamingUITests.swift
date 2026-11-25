import Testing
import GamingUI
import GamingPreview

@Test func consumerModuleUsesGamingUIModule() {
    #expect(GamingHubContent.title == "Gaming Hub")
    #expect(GamingHubContent.playerName == "Player One")
    _ = GamingPreviewScreen()
}
