
import Foundation


private let defaultCalendar = Calendar.autoupdatingCurrent


private let isoDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    return formatter
}()


private func decodeDateComponents(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>,
    components: Set<Calendar.Component>
) throws -> DateComponents {

    let value = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.value
    )

    guard let date = isoDateFormatter.date(from: value) else {
        throw DecodingError.invalidDate(value)
    }

    let calendar = try valueContainer.superDecoder().userInfo[calendarUserInfoKey] as? Calendar
        ?? defaultCalendar

    return calendar.dateComponents(components, from: date)
}


private func decodeYear(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year]
    )
    return .year(components)
}


private func decodeMonth(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year, .month]
    )
    return .month(components)
}


private func decodeDay(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year, .month, .day]
    )
    return .day(components)
}


private func decodeHour(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year, .month, .day, .hour]
    )
    return .hour(components)
}


private func decodeMinute(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year, .month, .day, .hour, .minute]
    )
    return .minute(components)
}


private func decodeSecond(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> SingleTimeValue {
    let components = try decodeDateComponents(
        valueContainer: valueContainer,
        components: [.timeZone, .year, .month, .day, .hour, .minute, .second]
    )
    return .second(components)
}


private func decodeBeforeTime(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> TimeValue {
    let singleTime = try decodeSingleTime(valueContainer: valueContainer)
    return .before(singleTime)
}


internal func decodeAfterTime(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> TimeValue {
    let singleTime = try decodeSingleTime(valueContainer: valueContainer)
    return .after(singleTime)
}


internal func decodeBetweenTime(
    fromValueContainer: KeyedDecodingContainer<ValueCodingKeys>,
    toValueContainer: KeyedDecodingContainer<ValueCodingKeys>
    ) throws -> TimeValue {
    let fromValue = try decodeSingleTime(valueContainer: fromValueContainer)
    let toValue = try decodeSingleTime(valueContainer: toValueContainer)
    return .between(fromValue, toValue)
}


internal func decodeSingleTime(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> SingleTimeValue {
    let grainString = try valueContainer.decode(
        String.self,
        forKey: ValueCodingKeys.grain
    )

    guard let grain = TimeGrain(rawValue: grainString) else {
        throw DecodingError.invalidTimeGrain(grainString)
    }

    switch grain {
    case .year:
        return try decodeYear(valueContainer: valueContainer)
    case .month:
        return try decodeMonth(valueContainer: valueContainer)
    case .day:
        return try decodeDay(valueContainer: valueContainer)
    case .hour:
        return try decodeHour(valueContainer: valueContainer)
    case .minute:
        return try decodeMinute(valueContainer: valueContainer)
    case .second:
        return try decodeSecond(valueContainer: valueContainer)
    }
}


internal func decodeIntervalTime(
    valueContainer: KeyedDecodingContainer<ValueCodingKeys>
) throws -> TimeValue {

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
        return try decodeBetweenTime(
            fromValueContainer: fromValueContainer,
            toValueContainer: toValueContainer
        )
    } else if hasFrom {
        let fromValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .from
        )
        return try decodeAfterTime(valueContainer: fromValueContainer)
    } else if hasTo {
        let toValueContainer = try valueContainer.nestedContainer(
            keyedBy: ValueCodingKeys.self,
            forKey: .to
        )
        return try decodeBeforeTime(valueContainer: toValueContainer)
    }

    throw DecodingError.missingIntervalProperties(valueContainer)
}
