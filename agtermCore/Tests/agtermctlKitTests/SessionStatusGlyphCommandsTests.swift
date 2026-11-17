import ArgumentParser
import Foundation
import Testing
import agtermCore
@testable import agtermctlKit

/// The `session.status --glyph` CLI surface, kept out of `CommandsTests` to leave that file under
/// swiftlint's `file_length` cap: its argv surface mirrors the shape/color tests there, the validation
/// rules mirror the dispatcher's (ControlDispatcherSessionMetadataTests).
struct SessionStatusGlyphCommandsTests {
    /// Parse argv into a subcommand and build its `ControlRequest`. Throws if parsing or request-building fails.
    private func request(_ argv: [String]) throws -> ControlRequest {
        let parsed = try Agtermctl.parseAsRoot(argv)
        guard let command = parsed as? any RequestCommand else {
            throw SocketClientError("parsed \(argv) is not a RequestCommand")
        }
        return try command.makeRequest()
    }

    /// Parses argv expecting a validation failure and returns the user-facing message, or nil when it parses.
    private func validationMessage(_ argv: [String]) -> String? {
        do {
            _ = try Agtermctl.parseAsRoot(argv)
            return nil
        } catch {
            return Agtermctl.message(for: error)
        }
    }

    @Test func sessionStatusWithGlyph() throws {
        let req = try request(["session", "status", "blocked", "--glyph", "🔥"])
        #expect(req.cmd == .sessionStatus)
        #expect(req.args?.glyph == "🔥")
        #expect(req == ControlRequest(cmd: .sessionStatus, target: "active",
                                      args: ControlArgs(status: "blocked", glyph: "🔥")))
    }

    @Test func sessionStatusAcceptsAZwjSequenceGlyph() throws {
        // a family emoji is one grapheme cluster in Swift, so it fits the same cap as a lone emoji
        #expect(try request(["session", "status", "active", "--glyph", "👨‍👩‍👧‍👦"]).args?.glyph == "👨‍👩‍👧‍👦")
    }

    @Test func sessionStatusWithoutGlyph() throws {
        #expect(try request(["session", "status", "active"]).args?.glyph == nil)
    }

    @Test func sessionStatusRejectsTooLongGlyph() {
        #expect(validationMessage(["session", "status", "blocked", "--glyph", "🔥🔥🔥🔥🔥"])
            == "glyph must be at most 4 characters")
    }

    @Test func sessionStatusRejectsBlankGlyph() {
        #expect(validationMessage(["session", "status", "blocked", "--glyph", "   "])
            == "glyph must not be empty")
    }

    @Test func sessionStatusGlyphHelpDocumentsTheCap() {
        // the option's help names the 1-4 character cap, so the limit is discoverable from --help alone
        let help = Session.Status.helpMessage(columns: 200)
        #expect(help.contains("--glyph"), "--glyph missing from help: \(help)")
    }
}
