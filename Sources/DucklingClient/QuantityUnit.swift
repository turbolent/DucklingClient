
public enum QuantityUnit: RawRepresentable, Equatable {
    case defined(DefinedQuantityUnit)
    case custom(String)

    public init?(rawValue: String) {
        if let defined = DefinedQuantityUnit(rawValue: rawValue) {
            self = .defined(defined)
        } else {
            self = .custom(rawValue)
        }
    }

    public var rawValue: String {
        switch self {
        case .defined(let defined):
            return defined.rawValue
        case .custom(let custom):
            return custom
        }
    }
}


public enum DefinedQuantityUnit: String, Equatable {
    case bowl
    case cup
    case dish
    case gram
    case ounce
    case pint
    case pound
    case quart
    case tablespoon
    case teaspoon
    case unnamed
}
