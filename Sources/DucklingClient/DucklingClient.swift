import Foundation
import Result


internal let calendarUserInfoKey = CodingUserInfoKey(rawValue: "calendar")!


public final class DucklingClient {

    public typealias Completion = (Result<[Entity], Error>) -> Void

    public enum Error: Swift.Error {
        case failedToConstructURL
        case failedResponse(Swift.Error)
        case invalidResponse
    }

    private struct Constants {
        static let defaultTimeoutIntervalForRequest: TimeInterval = 10
    }

    public let baseURL: URL
    private let session: URLSession

    public init(baseURL: URL, sessionConfiguration: URLSessionConfiguration? = nil) {
        self.baseURL = baseURL
        let sessionConfiguration = sessionConfiguration ?? {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = Constants.defaultTimeoutIntervalForRequest
            return config
            }()
        self.session = URLSession(configuration: sessionConfiguration)
    }

    public func parse(
        sentence: String,
        dimensions: Set<Dimension>? = nil,
        calendar: Calendar = Calendar.autoupdatingCurrent,
        completion: @escaping Completion
    ) throws {
        guard let url = URL(string: "/parse", relativeTo: self.baseURL) else {
            throw Error.failedToConstructURL
        }

        let request = DucklingClient.makeRequest(
            url: url,
            sentence: sentence,
            dimensions: dimensions,
            timeZone: calendar.timeZone
        )

        let completionHandler = DucklingClient.makeCompletionHandler(
            calendar: calendar,
            completion: completion
        )
        session.dataTask(
            with: request, completionHandler:
            completionHandler
        ).resume()
    }

    private static func makeRequest(
        url: URL,
        sentence: String,
        dimensions: Set<Dimension>?,
        timeZone: TimeZone
    ) -> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type"
        )

        var urlComponents = URLComponents()
        urlComponents.queryItems = [
            URLQueryItem(name: "text", value: sentence),
            URLQueryItem(name: "tz", value: timeZone.identifier)
        ]
        if let dimensions = dimensions {
            let dims = dimensions.map { $0.rawValue }.description
            urlComponents.queryItems?
                .append(URLQueryItem(name: "dims", value: dims))
        }

        request.httpBody = urlComponents.query?.data(using: .utf8)
        return request
    }

    private static func makeCompletionHandler(
        calendar: Calendar,
        completion: @escaping Completion
    )
        -> (Data?, URLResponse?, Swift.Error?) -> Void
    {
        return { (data, response, error) in
            if let error = error {
                completion(.failure(.failedResponse(error)))
                return
            }

            let decoder = JSONDecoder()
            decoder.userInfo = [calendarUserInfoKey: calendar]

            guard
                let response = response as? HTTPURLResponse,
                response.statusCode == 200,
                let data = data,
                let tokens = try? decoder.decode([Entity].self, from: data)
                else {
                    completion(.failure(.invalidResponse))
                    return
            }

            completion(.success(tokens))
        }
    }
}
