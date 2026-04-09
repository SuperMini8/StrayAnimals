//
//  MockLoader.swift
//  StrayAnimals
//
//  Created by ElmaYeh on 2026/4/8.
//

import Foundation
import Combine

final class MockLoader: APIClientProtocol {
    
    func sendRequest<E>(with endpoint: E) -> AnyPublisher<E.response, WebServiceError> where E : EndpointType {
        // 先找到 JSON 檔案
        guard let fileName = endpoint.mockFileName,
              let url = Bundle.main.url(forResource: fileName, withExtension: "json"),
              let data = try? Data(contentsOf: url)
        else {
            return Fail(error: .invalidResponse).eraseToAnyPublisher()
        }
        do {
            let result = try JSONDecoder.apiDefault.decode(E.response.self, from: data)
            return Just(result)
                .setFailureType(to: WebServiceError.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .decodeError(error)).eraseToAnyPublisher()
        }
        
    }
    
}
