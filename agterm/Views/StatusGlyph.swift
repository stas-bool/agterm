import agtermCore
import SwiftUI

/// A small SF-Symbol agent-status glyph for the attention list — the status's symbol tinted with the
/// configured status color, mirroring the sidebar's AppKit `StatusIconView`. Both surfaces draw from the
/// SAME resolvers (`GhosttyApp.statusSymbolName(for:override:)` + `.statusColor(for:override:)`) so they
/// can't drift, including the per-call `session.status --shape`/`--color` overrides. Only ever built for
/// a non-idle status (idle has no symbol and is filtered out before any glyph is shown).
struct StatusGlyph: View {
    let status: AgentStatus
    /// Optional per-call `#rrggbb` tint override (the session's `AgentIndicator.color`); nil = the
    /// Settings-configured status color.
    var colorHex: String?
    /// Optional per-call silhouette override (the session's `AgentIndicator.shape`); nil = this status's
    /// Settings shape, else the default plain circle.
    var shape: StatusShape?
    /// Optional per-call emoji/text glyph (the session's `AgentIndicator.glyph`); set draws the text
    /// instead of the symbol, in its own colors — a color emoji ignores `colorHex`.
    var glyph: String?

    private var swiftUIWeight: Font.Weight {
        GhosttyApp.shared.statusSymbolWeight(for: status, override: shape) == .heavy ? .heavy : .regular
    }

    var body: some View {
        if let glyph {
            Text(glyph)
        } else {
            Image(systemName: GhosttyApp.shared.statusSymbolName(for: status, override: shape))
                .fontWeight(swiftUIWeight)
                .foregroundStyle(Color(nsColor: GhosttyApp.shared.statusColor(for: status, override: colorHex)))
        }
    }
}
