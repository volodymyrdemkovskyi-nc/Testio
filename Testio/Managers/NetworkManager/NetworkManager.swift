//
//  NetworkManager.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 25/06/2025.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    func executeGetRequest<T: Decodable>(atEndpoint: URL, expecting: T.Type, headers: [String: String]?) async throws -> T
    func executePostRequest<T: Decodable, U: Encodable>(atEndpoint: URL, withPayload: U, expecting: T.Type, headers: [String: String]?) async throws -> T
}

struct NetworkManager: NetworkManagerProtocol {
    // MARK: - Nested Enums
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    enum ContentType: String {
        case json = "application/json"
    }

    enum NetworkError: LocalizedError, Equatable {
        case malformedResponse(url: URL)
        case accessDenied
        case invalidEndpoint
        case unexpectedIssue

        var errorDescription: String? {
            switch self {
            case .malformedResponse(url: let url):
                return "Malformed response from \(url)"
            case .accessDenied:
                return "Access to the resource was denied"
            case .invalidEndpoint:
                return "The provided endpoint is invalid"
            case .unexpectedIssue:
                return "An unexpected issue occurred"
            }
        }
    }

    // MARK: - Public Methods
    func executeGetRequest<T: Decodable>(atEndpoint: URL, expecting: T.Type, headers: [String: String]? = nil) async throws -> T {
        var request = prepareRequest(for: atEndpoint, method: .get, payload: nil, headers: headers)
        request = request.setHeaders()
        logRequest(request)
        let (data, response) = try await fetchData(with: request)
        return try parseResponse(data, response: response, for: atEndpoint)
    }

    func executePostRequest<T: Decodable, U: Encodable>(atEndpoint: URL, withPayload: U, expecting: T.Type, headers: [String: String]? = nil) async throws -> T {
        var request = prepareRequest(for: atEndpoint, method: .post, payload: withPayload, headers: headers)
        request = request.setHeaders()
        logRequest(request)
        let (data, response) = try await fetchData(with: request)
        return try parseResponse(data, response: response, for: atEndpoint)
    }

    // MARK: - Private Helpers
    private func prepareRequest(for endpoint: URL, method: HTTPMethod, payload: Encodable? = nil, headers: [String: String]? = nil) -> URLRequest {
        var request = URLRequest(url: endpoint)
        request = request.setRequestMethod(httpMethod: method)
        if let payload = payload {
            request = request.attachRequestBody(dataPayload: payload)
        }
        if let headers = headers {
            headers.forEach { key, value in
                request = request.setCustomHeader(value: value, forField: key)
            }
        }
        return request
    }

    private func fetchData(with request: URLRequest) async throws -> (Data, URLResponse) {
        return try await URLSession.shared.data(for: request)
    }

    private func parseResponse<T: Decodable>(_ data: Data, response: URLResponse, for endpoint: URL) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.malformedResponse(url: endpoint)
        }
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 401:
            // Не скидаємо токен автоматично, це має робити виклик
            throw NetworkError.accessDenied
        default:
            throw NetworkError.malformedResponse(url: endpoint)
        }
    }

    private func logRequest(_ request: URLRequest) {
        print("📡 Request: \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "NO URL")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }
}
