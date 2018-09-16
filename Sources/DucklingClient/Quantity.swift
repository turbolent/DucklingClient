
private func decodeUnderQuantity(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> QuantityValue {
    let singleQuantity = try decodeSingleQuantity(valueContainer: valueContainer)
    return .under(singleQuantity)
}


private func decodeAboveQuantity(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> QuantityValue {
    let singleQuantity = try decodeSingleQuantity(valueContainer: valueContainer)
    return .above(singleQuantity)
}


private func decodeBetweenQuantity(
    fromValueContainer: KeyedDecodingContainer<ValueCodingKeys>,
    toValueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> QuantityValue {
    let fromValue = try decodeSingleQuantity(valueContainer: fromValueContainer)
    let toValue = try decodeSingleQuantity(valueContainer: toValueContainer)
    return .between(fromValue, toValue)
}


internal func decodeSingleQuantity(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> SingleQuantityValue {

    let value = try valueContainer.decode(
        Double.self,
        forKey: ValueCodingKeys.value
    )

    let unitString = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.unit
    )

    guard let unit = QuantityUnit(rawValue: unitString) else {
        throw DecodingError.invalidQuantityUnit(unitString)
    }

    return SingleQuantityValue(value: value, unit: unit)
}


internal func decodeIntervalQuantity(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> QuantityValue {

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
        return try decodeBetweenQuantity(
            fromValueContainer: fromValueContainer,
            toValueContainer: toValueContainer
        )
    } else if hasFrom {
        let fromValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .from
        )
        return try decodeAboveQuantity(valueContainer: fromValueContainer)
    } else if hasTo {
        let toValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .to
        )
        return try decodeUnderQuantity(valueContainer: toValueContainer)
    }

    throw DecodingError.missingIntervalProperties(valueContainer)
}
