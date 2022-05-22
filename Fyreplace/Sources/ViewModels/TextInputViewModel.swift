import ReactiveSwift

protocol TextInputViewModel {
    var isLoading: MutableProperty<Bool> { get }
    var text: MutableProperty<String> { get }
}
