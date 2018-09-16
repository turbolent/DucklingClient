
public enum Dimension: String, Decodable {
    case time = "time"
    case numeral = "number"
    case ordinal = "ordinal"
    case distance = "distance"
    case email = "email"
    case url = "url"
    // TODO:
    case regexMatch = "regex"
    case duration = "duration"
    case amountOfMoney = "amount-of-money"
    case phoneNumber = "phone-number"
    case quantity = "quantity"
    case temperature = "temperature"
    case timeGrain = "time-grain"
    case volume = "volume"
}
