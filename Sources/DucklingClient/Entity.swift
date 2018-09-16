
import Foundation


public enum DecodingError: Error {
    case invalidDate(String)
    case invalidValue(
        KeyedDecodingContainer<ValueCodingKeys>,
        Dimension
    )
    case invalidTimeGrain(String)
    case missingIntervalProperties(KeyedDecodingContainer<ValueCodingKeys>)
    case invalidDistanceUnit(String)
}


private enum EntityCodingKeys: String, CodingKey {
    case dimension = "dim"
    case body
    case start
    case end
    case value
}


public enum ValueCodingKeys: CodingKey {
    case type
    case value
    case grain
    case unit
    case from
    case to
}


private enum ValueType: String {
    case value
    case interval
}


private func decodeNumeral(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> Value {
    let value = try valueContainer.decode(
        Double.self,
        forKey: ValueCodingKeys.value
    )
    return .numeral(value)
}


private func decodeOrdinal(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> Value {
    let value = try valueContainer.decode(
        Int.self,
        forKey: ValueCodingKeys.value
    )
    return .ordinal(value)
}


private func decodeEmail(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> Value {
    let value = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.value
    )
    return .email(value)
}


private func decodeURL(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> Value {
    let value = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.value
    )
    return .url(value)
}


private func decodeValue(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>,
    dimension: Dimension
) throws -> Value {
    let valueType = try valueContainer.decodeIfPresent(
        String.self,
        forKey: ValueCodingKeys.type
    ).flatMap {
        ValueType(rawValue: $0)
    }

    switch (dimension, valueType) {
    case (.time, .value?):
        let time = try decodeSingleTime(valueContainer: valueContainer)
        return .time(.single(time))
    case (.time, .interval?):
        let time = try decodeTimeInterval(valueContainer: valueContainer)
        return .time(time)
    case (.distance, .value?):
        let distance = try decodeSingleDistance(valueContainer: valueContainer)
        return .distance(.single(distance))
    case (.distance, .interval?):
        let time = try decodeDistanceInterval(valueContainer: valueContainer)
        return .distance(time)
    case (.numeral, _):
        return try decodeNumeral(valueContainer: valueContainer)
    case (.ordinal, _):
        return try decodeOrdinal(valueContainer: valueContainer)
    case (.email, _):
        return try decodeEmail(valueContainer: valueContainer)
    case (.url, _):
        return try decodeURL(valueContainer: valueContainer)
    default:
        throw DecodingError.invalidValue(valueContainer, dimension)
    }
}


public struct Entity: Decodable, Equatable {

    public let dimension: Dimension
    public let body: String
    public let start: Int
    public let end: Int
    public let value: Value

    public init(
        dimension: Dimension,
        body: String,
        start: Int,
        end: Int,
        value: Value
    ) {
        self.dimension = dimension
        self.body = body
        self.start = start
        self.end = end
        self.value = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EntityCodingKeys.self)

        dimension = try container.decode(Dimension.self, forKey: .dimension)
        body = try container.decode(String.self, forKey: .body)
        start = try container.decode(Int.self, forKey: .start)
        end = try container.decode(Int.self, forKey: .end)

        let valueContainer = try container.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .value
        )
        value = try decodeValue(
            valueContainer: valueContainer,
            dimension: dimension
        )
    }
}
