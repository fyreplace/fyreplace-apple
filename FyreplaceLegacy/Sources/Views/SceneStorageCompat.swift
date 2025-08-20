import SwiftUI

@propertyWrapper
struct SceneStorageCompat<Value>: DynamicProperty {
    @State var wrappedValue: Value

    init(wrappedValue: Value, _ key: String) {
        _wrappedValue = State(initialValue: wrappedValue)
    }
    
    init<T>(_ key: String) where Value == Optional<T> {
        _wrappedValue = State(initialValue: nil)
    }

    var projectedValue: Binding<Value> {
        $wrappedValue
    }
}
