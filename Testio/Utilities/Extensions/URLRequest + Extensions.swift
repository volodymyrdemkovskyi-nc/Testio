//
//  URLRequest + Extensions.swift
//  Testio
//
//  Created by Volodymyr Demkovskyi  on 28/06/2025.
//

import Foundation

extension URLRequest {

    func setHeaders() -> URLRequest {
        var request = self
        if let accessToken = AuthenticationSessionHandler.shared.accessToken{
            request = request.addAuthorizationCode(authCodeValue: accessToken)
        }
        return request.applyContentType(headerValue: .json)
    }

    func setRequestMethod(httpMethod: NetworkManager.HTTPMethod) -> URLRequest {
        var updatedRequest = self
        updatedRequest.httpMethod = httpMethod.rawValue
        return updatedRequest
    }

    func attachRequestBody(dataPayload: Encodable?) -> URLRequest {
        var updatedRequest = self
        guard let payload = dataPayload else { return updatedRequest }
        updatedRequest.httpBody = try? JSONEncoder().encode(payload)
        return updatedRequest
    }

    private func applyContentType(headerValue: NetworkManager.ContentType) -> URLRequest {
        return setCustomHeader(value: headerValue.rawValue, forField: "Content-Type")
    }

    private func addAuthorizationCode(authCodeValue: String) -> URLRequest {
        return setCustomHeader(value: authCodeValue, forField: "Authorization")
    }

    func setCustomHeader(value: String, forField headerField: String) -> URLRequest {
        var updatedRequest = self
        updatedRequest.setValue(value, forHTTPHeaderField: headerField)
        return updatedRequest
    }
}
