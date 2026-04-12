import Combine

protocol TextInputViewModel {
    var textPublisher: AnyPublisher<String, Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
}
