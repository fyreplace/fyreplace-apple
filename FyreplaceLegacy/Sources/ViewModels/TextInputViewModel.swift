import ReactiveSwift

protocol TextInputViewModel {
    var text: MutableProperty<String> { get }
    var isLoading: MutableProperty<Bool> { get }
}
