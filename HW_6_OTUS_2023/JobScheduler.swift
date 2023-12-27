//
//  JobScheduler.swift
//  HW_6_OTUS_2023
//
//  Created by Филатов Олег Олегович on 21.12.2023.
//

import Foundation

actor JobScheduler {
    private let concurrency: Int
    private var running: Int = 0
    private var queue: [CheckedContinuation<Void, Error>] = .init()

    public init(concurrency: Int) {
        self.concurrency = concurrency
    }

    deinit {
        for continuation in queue {
            continuation.resume(throwing: CancellationError())
        }
    }

    public func addJob<T>(operation: @escaping @Sendable () async throws -> T) async throws -> T {
        try Task.checkCancellation()

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.append(continuation)
            increaseRunning()
        }
        defer {
            running -= 1
            increaseRunning()
        }

        try Task.checkCancellation()
        return try await operation()
    }

    private func increaseRunning() {
        guard !queue.isEmpty else { return }
        guard running < concurrency else { return }

        running += 1
        let continuation = queue.removeFirst()
        continuation.resume()
    }
}
