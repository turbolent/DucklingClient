

private func decodeBelowDistance(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> DistanceValue {
    let singleDistance = try decodeSingleDistance(valueContainer: valueContainer)
    return .below(singleDistance)
}


private func decodeAboveDistance(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> DistanceValue {
    let singleDistance = try decodeSingleDistance(valueContainer: valueContainer)
    return .above(singleDistance)
}


private func decodeBetweenDistance(
    fromValueContainer: KeyedDecodingContainer<ValueCodingKeys>,
    toValueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> DistanceValue {
    let fromValue = try decodeSingleDistance(valueContainer: fromValueContainer)
    let toValue = try decodeSingleDistance(valueContainer: toValueContainer)
    return .between(fromValue, toValue)
}


internal func decodeSingleDistance(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> SingleDistanceValue {

    let value = try valueContainer.decode(
        Double.self,
        forKey: ValueCodingKeys.value
    )

    let unitString = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.unit
    )

    guard let unit = DistanceUnit(rawValue: unitString) else {
        throw DecodingError.invalidDistanceUnit(unitString)
    }

    return SingleDistanceValue(value: value, unit: unit)
}


internal func decodeIntervalDistance(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> DistanceValue {

    let hasFrom = valueContainer.contains(.from)
    let hasTo = valueContainer.contains(.to)

    if hasFrom && hasTo {
        let fromValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .from
        )
        let toValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .to
        )
        return try decodeBetweenDistance(
            fromValueContainer: fromValueContainer,
            toValueContainer: toValueContainer
        )
    } else if hasFrom {
        let fromValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .from
        )
        return try decodeAboveDistance(valueContainer: fromValueContainer)
    } else if hasTo {
        let toValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .to
        )
        return try decodeBelowDistance(valueContainer: toValueContainer)
    }

    throw DecodingError.missingIntervalProperties(valueContainer)
}
