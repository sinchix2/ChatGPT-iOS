import Foundation

// MARK: - Server-Sent Events AsyncStream Parser

public enum SSEError: Error, LocalizedError {
    case invalidData
    case streamAborted(String)
    case serverError(statusCode: Int, message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidData:
            return "Received invalid or unparseable SSE chunk."
        case .streamAborted(let reason):
            return "Streaming response was aborted: \(reason)"
        case .serverError(let code, let msg):
            return "Server responded with code \(code): \(msg)"
        }
    }
}

public struct SSEStreamReader: Sendable {
    private let decoder: JSONDecoder

    public init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    public func parseStream(
        bytes: URLSession.AsyncBytes,
        response: URLResponse
    ) -> AsyncThrowingStream<ConversationStreamChunk, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
                    continuation.finish(throwing: SSEError.serverError(
                        statusCode: httpResponse.statusCode,
                        message: "HTTP Error \(httpResponse.statusCode)"
                    ))
                    return
                }

                var currentDataLines: [String] = []

                do {
                    for try await line in bytes.lines {
                        let trimmed = line.trimmingCharacters(in: .whitespaces)

                        if trimmed.isEmpty {
                            // Blank line denotes end of SSE event block
                            if !currentDataLines.isEmpty {
                                let payloadString = currentDataLines.joined(separator: "\n")
                                currentDataLines.removeAll()

                                if payloadString == "[DONE]" {
                                    continuation.finish()
                                    return
                                }

                                guard let data = payloadString.data(using: .utf8) else { continue }
                                do {
                                    let chunk = try decoder.decode(ConversationStreamChunk.self, from: data)
                                    continuation.yield(chunk)
                                } catch {
                                    // Non-fatal parse failure on partial metadata chunk
                                }
                            }
                            continue
                        }

                        if trimmed.hasPrefix("data:") {
                            let dataContent = String(trimmed.dropFirst(5)).trimmingCharacters(in: .whitespaces)
                            currentDataLines.append(dataContent)
                        } else if trimmed.hasPrefix("event:") {
                            // Event type tag (e.g. event: message, event: ping)
                        } else if trimmed.hasPrefix(":") {
                            // SSE comment / keep-alive heartbeat ping
                        }
                    }

                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
