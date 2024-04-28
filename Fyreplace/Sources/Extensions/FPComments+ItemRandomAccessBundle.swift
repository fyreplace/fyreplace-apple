extension FPComments: ItemRandomAccessBundle {
    typealias Item = FPComment

    var items: [Item] { comments }
}
