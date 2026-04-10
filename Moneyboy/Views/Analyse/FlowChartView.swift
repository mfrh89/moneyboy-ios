import SwiftUI

private struct SankeyNode: Identifiable {
    let id: String
    let label: String
    let value: Double
    var x: CGFloat = 0
    var y: CGFloat = 0
    var height: CGFloat = 0
    let color: Color
    var column: Int = 0
}

private struct SankeyLink {
    let sourceID: String
    let targetID: String
    let value: Double
    let color: Color
}

struct FlowChartView: View {
    let items: [FinanceItem]

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    private let nodeWidth: CGFloat = 14

    // Distinct colors — no two should look similar on dark mode
    private let palette: [Color] = [
        Color(red: 0.2, green: 0.5, blue: 1.0),   // bright blue
        Color(red: 1.0, green: 0.6, blue: 0.1),   // orange
        Color(red: 0.7, green: 0.2, blue: 0.7),   // magenta
        Color(red: 1.0, green: 0.3, blue: 0.3),   // red
        Color(red: 0.0, green: 0.7, blue: 0.7),   // teal
        Color(red: 0.9, green: 0.8, blue: 0.1),   // yellow
        Color(red: 0.4, green: 0.3, blue: 0.8),   // indigo
        Color(red: 0.3, green: 0.8, blue: 0.5),   // mint
        Color(red: 1.0, green: 0.4, blue: 0.6),   // pink
        Color(red: 0.6, green: 0.4, blue: 0.2),   // brown
        Color(red: 0.0, green: 0.6, blue: 1.0),   // sky
        Color(red: 0.8, green: 0.5, blue: 0.2),   // amber
    ]

    var body: some View {
        GeometryReader { geo in
            let (nodes, links) = buildSankey(size: geo.size)

            Canvas { ctx, size in
                drawLinks(ctx: ctx, nodes: nodes, links: links)
                drawNodes(ctx: ctx, size: size, nodes: nodes)
            }
            .scaleEffect(scale, anchor: .center)
            .offset(x: offset.width, y: offset.height)
            .gesture(
                MagnificationGesture()
                    .onChanged { val in
                        scale = min(max(lastScale * val, 0.5), 4.0)
                    }
                    .onEnded { _ in
                        lastScale = scale
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { val in
                        offset = CGSize(
                            width: lastOffset.width + val.translation.width,
                            height: lastOffset.height + val.translation.height
                        )
                    }
                    .onEnded { _ in
                        lastOffset = offset
                    }
            )
        }
    }

    // MARK: - Build

    private func buildSankey(size: CGSize) -> ([String: SankeyNode], [SankeyLink]) {
        let incomeItems = items.filter { $0.type == .income && !$0.excluded }
        let expenseItems = items.filter { $0.type == .expense && !$0.excluded }
        let totalIncome = incomeItems.reduce(0) { $0 + $1.amount }
        let totalExpense = expenseItems.reduce(0) { $0 + $1.amount }
        let balance = totalIncome - totalExpense

        let padTop: CGFloat = 16
        let padBottom: CGFloat = 30
        let usableH = size.height - padTop - padBottom
        let gap: CGFloat = 4

        // 3 columns — all fit within screen width
        let col1X: CGFloat = 6
        let col2X = size.width * 0.28
        let col3X = size.width * 0.52

        var nodes: [String: SankeyNode] = [:]
        var links: [SankeyLink] = []
        var colorIndex = 0

        func nextColor() -> Color {
            let c = palette[colorIndex % palette.count]
            colorIndex += 1
            return c
        }

        // Income nodes (left)
        var incomeY = padTop
        for item in incomeItems {
            let h = CGFloat(item.amount / max(totalIncome, 1)) * usableH
            let color = nextColor()
            var node = SankeyNode(id: "in-\(item.id)", label: item.title, value: item.amount, color: color, column: 0)
            node.x = col1X; node.y = incomeY; node.height = max(h, 4)
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: node.id, targetID: "budget", value: item.amount, color: color))
            incomeY += h + gap
        }

        // Budget (center)
        var budget = SankeyNode(id: "budget", label: "Budget", value: totalIncome, color: .gray, column: 1)
        budget.x = col2X; budget.y = padTop; budget.height = usableH
        nodes["budget"] = budget

        // Expense categories (right), sorted desc
        let grouped = Dictionary(grouping: expenseItems, by: { $0.category })
        let cats = grouped.keys.sorted {
            let a = grouped[$0]!.reduce(0) { $0 + $1.amount }
            let b = grouped[$1]!.reduce(0) { $0 + $1.amount }
            return a > b
        }
        var expenseY = padTop
        for cat in cats {
            let catItems = grouped[cat]!
            let catTotal = catItems.reduce(0) { $0 + $1.amount }
            let h = CGFloat(catTotal / max(totalIncome, 1)) * usableH
            let color = nextColor()
            var node = SankeyNode(id: "cat-\(cat)", label: cat, value: catTotal, color: color, column: 2)
            node.x = col3X; node.y = expenseY; node.height = max(h, 4)
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: "budget", targetID: node.id, value: catTotal, color: color))
            expenseY += h + gap
        }

        // Balance
        if balance > 0 {
            let h = CGFloat(balance / max(totalIncome, 1)) * usableH
            var node = SankeyNode(id: "available", label: "Available", value: balance, color: .green, column: 2)
            node.x = col3X; node.y = expenseY; node.height = max(h, 4)
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: "budget", targetID: "available", value: balance, color: .green))
        }

        return (nodes, links)
    }

    // MARK: - Draw

    private func drawLinks(ctx: GraphicsContext, nodes: [String: SankeyNode], links: [SankeyLink]) {
        var sourceOffsets: [String: CGFloat] = [:]
        var targetOffsets: [String: CGFloat] = [:]

        for link in links {
            guard let src = nodes[link.sourceID], let tgt = nodes[link.targetID] else { continue }
            let srcLinkH = CGFloat(link.value / max(src.value, 1)) * src.height
            let tgtLinkH = CGFloat(link.value / max(tgt.value, 1)) * tgt.height
            let srcOff = sourceOffsets[link.sourceID, default: 0]
            let tgtOff = targetOffsets[link.targetID, default: 0]

            let srcX = src.x + nodeWidth
            let tgtX = tgt.x
            let srcY = src.y + srcOff
            let tgtY = tgt.y + tgtOff

            var path = Path()
            path.move(to: CGPoint(x: srcX, y: srcY))
            path.addCurve(
                to: CGPoint(x: tgtX, y: tgtY),
                control1: CGPoint(x: (srcX + tgtX) / 2, y: srcY),
                control2: CGPoint(x: (srcX + tgtX) / 2, y: tgtY)
            )
            path.addLine(to: CGPoint(x: tgtX, y: tgtY + tgtLinkH))
            path.addCurve(
                to: CGPoint(x: srcX, y: srcY + srcLinkH),
                control1: CGPoint(x: (srcX + tgtX) / 2, y: tgtY + tgtLinkH),
                control2: CGPoint(x: (srcX + tgtX) / 2, y: srcY + srcLinkH)
            )
            path.closeSubpath()
            ctx.fill(path, with: .color(link.color.opacity(0.3)))

            sourceOffsets[link.sourceID] = srcOff + srcLinkH
            targetOffsets[link.targetID] = tgtOff + tgtLinkH
        }
    }

    private func drawNodes(ctx: GraphicsContext, size: CGSize, nodes: [String: SankeyNode]) {
        for node in nodes.values {
            let rect = CGRect(x: node.x, y: node.y, width: nodeWidth, height: node.height)
            ctx.fill(Path(roundedRect: rect, cornerRadius: 3), with: .color(node.color))

            let centerY = node.y + node.height / 2

            switch node.column {
            case 0:
                // Left: label right of node
                let lx = node.x + nodeWidth + 6
                drawLabel(ctx: ctx, name: node.label, value: node.value, x: lx, centerY: centerY, anchor: .leading, height: node.height)
            case 1:
                // Center: label centered on node
                let midX = node.x + nodeWidth / 2
                drawLabel(ctx: ctx, name: node.label, value: node.value, x: midX, centerY: centerY, anchor: .center, height: node.height)
            default:
                // Right: label right of node
                let lx = node.x + nodeWidth + 6
                drawLabel(ctx: ctx, name: node.label, value: node.value, x: lx, centerY: centerY, anchor: .leading, height: node.height)
            }
        }
    }

    private func drawLabel(ctx: GraphicsContext, name: String, value: Double, x: CGFloat, centerY: CGFloat, anchor: UnitPoint, height: CGFloat) {
        if height > 30 {
            ctx.draw(
                Text(name).font(.system(size: 13, weight: .medium)),
                at: CGPoint(x: x, y: centerY - 9),
                anchor: anchor
            )
            ctx.draw(
                Text(value.eurFormatted).font(.system(size: 11)).foregroundStyle(.secondary),
                at: CGPoint(x: x, y: centerY + 8),
                anchor: anchor
            )
        } else {
            let combined = Text(name).font(.system(size: 11, weight: .medium))
                + Text("  \(value.eurFormatted)").font(.system(size: 10)).foregroundStyle(.secondary)
            ctx.draw(combined, at: CGPoint(x: x, y: centerY), anchor: anchor)
        }
    }
}
