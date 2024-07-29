import Combine

extension AnyPublisher {
    static var empty: Self {
        PassthroughSubject<Output, Failure>().eraseToAnyPublisher()
    }
}
