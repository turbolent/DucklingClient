import XCTest
@testable import DucklingClient

final class DucklingClientTests: XCTestCase {

    func testSecond() throws {
        try expectParse(
            "6 seconds before six thirty on March 17 2018",
            [
                Entity(dimension: .time,
                       body: "6 seconds before six thirty on March 17 2018",
                       start: 0, end: 44,
                       value: .time(.single(.second(DateComponents(
                            timeZone: Calendar.current.timeZone,
                            year: 2018, month: 3, day: 17, hour: 18,
                            minute: 29, second: 54)))))
            ]
        )
    }

    func testMinute() throws {
        try expectParse(
            "six thirty on Mar 7 2018",
            [
                Entity(dimension: .time,
                       body: "six thirty on Mar 7 2018",
                       start: 0, end: 24,
                       value: .time(.single(.minute(DateComponents(
                            timeZone: Calendar.current.timeZone,
                            year: 2018, month: 3, day: 7, hour: 6,
                            minute: 30)))))
            ]
        )
    }

    func testHour() throws {
        try expectParse(
            "6 o'clock on Mar 7 2018",
            [
                Entity(dimension: .time,
                       body: "6 o'clock on Mar 7 2018",
                       start: 0, end: 23,
                       value: .time(.single(.hour(DateComponents(
                           timeZone: Calendar.current.timeZone,
                           year: 2018, month: 3, day: 7, hour: 6)))))
            ]
        )
    }

    func testDay() throws {
        try expectParse(
            "who was born on March 17 2018",
            [
                Entity(dimension: .time,
                       body: "on March 17 2018",
                       start: 13, end: 29,
                       value: .time(.single(.day(DateComponents(
                            timeZone: Calendar.current.timeZone,
                            year: 2018, month: 3, day: 17)))))
            ]
        )
    }

    func testMonth() throws {
        try expectParse(
            "who was born in March 2019",
            [
                Entity(dimension: .time,
                       body: "in March 2019",
                       start: 13, end: 26,
                       value: .time(.single(.month(DateComponents(
                           timeZone: Calendar.current.timeZone,
                           year: 2019, month: 3)))))
            ]
        )
    }

    func testYear() throws {
        try expectParse(
            "who was born in 2016",
            [
                Entity(dimension: .time,
                       body: "in 2016",
                       start: 13, end: 20,
                       value: .time(.single(.year(DateComponents(
                           timeZone: Calendar.current.timeZone,
                           year: 2016)))))
            ]
        )
    }

    func testTimeBetween() throws {
        try expectParse(
            "from 2016 to 2018",
            [
                Entity(dimension: .time,
                       body: "from 2016 to 2018",
                       start: 0, end: 17,
                       value: .time(.between(
                           .year(DateComponents(
                               timeZone: Calendar.current.timeZone,
                               year: 2016)),
                           .year(DateComponents(
                               timeZone: Calendar.current.timeZone,
                               year: 2019)))))
            ]
        )
    }

    func testTimeBefore() throws {
        try expectParse(
            "until 2016",
            [
                Entity(dimension: .time,
                       body: "until 2016",
                       start: 0, end: 10,
                       value: .time(.before(
                           .year(DateComponents(
                               timeZone: Calendar.current.timeZone,
                               year: 2016)))))
            ]
        )
    }

    func testTimeAfter() throws {
        try expectParse(
            "since 2016",
            [
                Entity(dimension: .time,
                       body: "since 2016",
                       start: 0, end: 10,
                       value: .time(.after(
                           .year(DateComponents(
                               timeZone: Calendar.current.timeZone,
                               year: 2016)))))
            ]
        )
    }

    func testNumeral() throws {
        try expectParse(
            "five million",
            [
                Entity(dimension: .numeral,
                       body: "five million",
                       start: 0, end: 12,
                       value: .numeral(5_000_000))
            ]
        )
    }

    func testOrdinal() throws {
        try expectParse(
            "second",
            [
                Entity(dimension: .ordinal,
                       body: "second",
                       start: 0, end: 6,
                       value: .ordinal(2))
            ]
        )
    }

    func testDistance() throws {
        try expectParse(
            "five meters",
            [
                Entity(dimension: .distance,
                       body: "five meters",
                       start: 0, end: 11,
                       value: .distance(.single(SingleDistanceValue(value: 5, unit: .metre))))
            ]
        )
    }

    func testDistanceBetween() throws {
        try expectParse(
            "between five and six meters",
            [
                Entity(dimension: .distance,
                       body: "between five and six meters",
                       start: 0, end: 27,
                       value: .distance(.between(
                           SingleDistanceValue(value: 5, unit: .metre),
                           SingleDistanceValue(value: 6, unit: .metre))))
            ]
        )
    }

    func testDistanceBelow() throws {
        try expectParse(
            "less than 4 cm",
            [
                Entity(dimension: .distance,
                       body: "less than 4 cm",
                       start: 0, end: 14,
                       value: .distance(.below(SingleDistanceValue(value: 4, unit: .centimetre))))
            ]
        )
    }

    func testDistanceAbove() throws {
        try expectParse(
            "over 5\"",
            [
                Entity(dimension: .distance,
                       body: "over 5\"",
                       start: 0, end: 7,
                       value: .distance(.above(SingleDistanceValue(value: 5, unit: .inch))))
            ]
        )
    }

    func testEmail() throws {
        try expectParse(
            "test@example.org",
            [
                Entity(dimension: .email,
                       body: "test@example.org",
                       start: 0, end: 16,
                       value: .email("test@example.org"))
            ]
        )
    }

    func testURL() throws {
        try expectParse(
            "example.org",
            [
                Entity(dimension: .url,
                       body: "example.org",
                       start: 0, end: 11,
                       value: .url("example.org"))
            ]
        )
    }

    private func expectParse(_ sentence: String, _ expectedEntities: [Entity]) throws {
        let expectiation = self.expectation(description: "completion is called")

        let client = DucklingClient(baseURL: URL(string: "http://localhost:8000/")!)
        try client.parse(sentence: sentence) {
            defer {
                expectiation.fulfill()
            }

            guard case .success(let entities) = $0 else {
                XCTFail("should have succeeded")
                return
            }

            XCTAssertEqual(entities, expectedEntities)
        }

        waitForExpectations(timeout: 10) { error in
            error.map { XCTFail(String(describing: $0)) }
        }
    }

    static var allTests: [(String, (DucklingClientTests) -> () throws -> ())] = [
        ("testSecond", testSecond),
        ("testMinute", testMinute),
        ("testHour", testHour),
        ("testYear", testYear),
        ("testDay", testDay),
        ("testMonth", testMonth),
        ("testTimeBetween", testTimeBetween),
        ("testTimeAfter", testTimeAfter),
        ("testTimeBefore", testTimeBefore),
        ("testNumeral", testNumeral),
        ("testOrdinal", testOrdinal),
        ("testDistance", testDistance),
        ("testDistanceBetween", testDistanceBetween),
        ("testDistanceAbove", testDistanceAbove),
        ("testDistanceBelow", testDistanceBelow),
        ("testEmail", testEmail),
        ("testURL", testURL)
    ]
}
