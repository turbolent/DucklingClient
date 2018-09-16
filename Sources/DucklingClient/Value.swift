
import Foundation

public enum Value: Equatable {
    case time(TimeValue)
    case distance(DistanceValue)
    case ordinal(Int)
    case numeral(Double)
    case email(String)
    case url(String)
}

public indirect enum TimeValue: Equatable {
    case single(SingleTimeValue)
    case after(SingleTimeValue)
    case before(SingleTimeValue)
    case between(SingleTimeValue, SingleTimeValue)
}

public enum SingleTimeValue: Equatable {
    case year(DateComponents)
    case month(DateComponents)
    case day(DateComponents)
    case hour(DateComponents)
    case minute(DateComponents)
    case second(DateComponents)
    case date(DateComponents)
}

public indirect enum DistanceValue: Equatable {
    case single(SingleDistanceValue)
    case above(SingleDistanceValue)
    case below(SingleDistanceValue)
    case between(SingleDistanceValue, SingleDistanceValue)
}

public struct SingleDistanceValue: Equatable {
    public let value: Double
    public let unit: DistanceUnit
}
