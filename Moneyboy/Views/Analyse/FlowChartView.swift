import SwiftUI

private struct SankeyNode: Identifiable {
    let id: String
    let label: String
    let value: Double
    var x: CGFloat = 0
    var y: CGFloat = 0
    var height: CGFloat = 0
    let color: Color
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
    @State private var offset: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var magnifyBy: CGFloat = 1.0

    private let palette: [Color] = [
        .blue, .green, .orange, .purple, .red, .teal,
        .indigo, .mint, .pink, .cyan, .yellow, .brown
    ]

    var body: some View {
        GeometryReader { geo in
            let (nodes, links) = buildSankey(size: geo.size)
            Canvas { ctx, size in
                drawLinks(ctx: ctx, size: size, nodes: nodes, links: links)
                drawNodes(ctx: ctx, size: size, nodes: nodes)
            }
            .scaleEffect(scale * magnifyBy, anchor: .center)
            .offset(x: offset.width + dragOffset.width, y: offset.height + dragOffset.height)
            .gesture(
                MagnificationGesture()
                    .updating($magnifyBy) { val, state, _ in state = val }
                    .onEnded { scale = min(max(scale * $0, 0.5), 4.0) }
            )
            .simultaneousGesture(
                DragGesture()
                    .updating($dragOffset) { val, state, _ in state = val.translation }
                    .onEnded { offset = CGSize(width: offset.width + $0.translation.width,
                                               height: offset.height + $0.translation.height) }
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

        let pad: CGFloat = 40
        let nodeWidth: CGFloat = 16
        let col1X = pad
        let col2X = size.width / 2 - nodeWidth / 2
        let col3X = size.width - pad - nodeWidth
        let usableH = size.height - pad * 2

        var nodes: [String: SankeyNode] = [:]
        var links: [SankeyLink] = []

        // Income nodes (left column)
        var incomeY = pad
        for (i, item) in incomeItems.enumerated() {
            let h = CGFloat(item.amount / max(totalIncome, 1)) * usableH
            let color = palette[i % palette.count]
            var node = SankeyNode(id: "in-\(item.id)", label: item.title, value: item.amount, color: color)
            node.x = col1X; node.y = incomeY; node.height = h
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: node.id, targetID: "budget", value: item.amount, color: color))
            incomeY += h + 4
        }

        // Budget (center)
        var budget = SankeyNode(id: "budget", label: "Budget", value: totalIncome, color: .gray)
        budget.x = col2X; budget.y = pad; budget.height = usableH
        nodes["budget"] = budget

        // Expense nodes by category (right column)
        let grouped = Dictionary(grouping: expenseItems, by: { $0.category })
        let cats = grouped.keys.sorted()
        var expenseY = pad
        for (i, cat) in cats.enumerated() {
            let catItems = grouped[cat]!
            let catTotal = catItems.reduce(0) { $0 + $1.amount }
            let h = CGFloat(catTotal / max(totalIncome, 1)) * usableH
            let color = palette[(incomeItems.count + i) % palette.count]
            var node = SankeyNode(id: "cat-\(cat)", label: cat, value: catTotal, color: color)
            node.x = col3X; node.y = expenseY; node.height = h
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: "budget", targetID: node.id, value: catTotal, color: color))
            expenseY += h + 4
        }

        // Balance node
        if balance > 0 {
            let h = CGFloat(balance / max(totalIncome, 1)) * usableH
            var node = SankeyNode(id: "available", label: "Verfügbar", value: balance, color: .green)
            node.x = col3X; node.y = expenseY; node.height = h
            nodes[node.id] = node
            links.append(SankeyLink(sourceID: "budget", targetID: "available", value: balance, color: .green))
        }

        return (nodes, links)
    }

    // MARK: - Draw

    private func drawLinks(ctx: GraphicsContext, size: CGSize, nodes: [String: SankeyNode], links: [SankeyLink]) {
        let nodeWidth: CGFloat = 16
        for link in links {
            guard let src = nodes[link.sourceID], let tgt = nodes[link.targetID] else { continue }
            let linkH = CGFloat(link.value / max(src.value, 1)) * src.height
            let srcX = src.x + nodeWidth
            let tgtX = tgt.x
            var path = Path()
            path.move(to: CGPoint(x: srcX, y: src.y))
            path.addCurve(
                to: CGPoint(x: tgtX, y: tgt.y),
                control1: CGPoint(x: (srcX + tgtX) / 2, y: src.y),
                control2: CGPoint(x: (srcX + tgtX) / 2, y: tgt.y)
            )
            path.addLine(to: CGPoint(x: tgtX, y: tgt.y + min(linkH, tgt.height)))
            path.addCurve(
                to: CGPoint(x: srcX, y: src.y + linkH),
                control1: CGPoint(x: (srcX + tgtX) / 2, y: tgt.y + min(linkH, tgt.height)),
                control2: CGPoint(x: (srcX + tgtX) / 2, y: src.y + linkH)
            )
            path.closeSubpath()
            ctx.fill(path, with: .color(link.color.opacity(0.25)))
        }
    }

    private func drawNodes(ctx: GraphicsContext, size: CGSize, nodes: [String: SankeyNode]) {
        let nodeWidth: CGFloat = 16
        for node in nodes.values {
            let rect = CGRect(x: node.x, y: node.y, width: nodeWidth, height: node.height)
            ctx.fill(Path(roundedRect: rect, cornerRadius: 4), with: .color(node.color))

            let labelX = node.x < size.width / 3 ? node.x + nodeWidth + 6 : node.x - 6
            let anchor: UnitPoint = node.x < size.width / 3 ? .leading : .trailing
            ctx.draw(
                Text(node.label).font(.caption2),
                at: CGPoint(x: labelX, y: node.y + node.height / 2),
                anchor: anchor
            )
        }
    }
}
