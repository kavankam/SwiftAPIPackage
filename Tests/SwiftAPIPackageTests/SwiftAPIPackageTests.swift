import XCTest
@testable import SwiftAPIPackage

final class SwiftAPIPackageTests: XCTestCase {

    @MainActor
    func testFetchCurrentWeather() {
        let expectation = self.expectation(description: "Fetching weather data")
        let apiKey = "e2d616fa303b228659655e961d51a5f3" // Replace with your actual API key
        let client = WeatherAPIClient(apiKey: apiKey)

        client.fetchCurrentWeather(forCity: "London") { result in
            switch result {
            case .success(let weather):
                XCTAssertEqual(weather.name, "London")
                print("Current temperature in \(weather.name ?? "Unknown"): \(weather.main?.temp ?? 0)°C")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Error fetching weather data: \(error)")
                expectation.fulfill() // Ensure the expectation is fulfilled even on failure
            }
        }

        waitForExpectations(timeout: 10, handler: nil)
    }
}




