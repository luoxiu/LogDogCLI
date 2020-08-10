//
//  File.swift
//  
//
//  Created by jinxiangqiu on 2020/8/9.
//

import Foundation

private let shellQueue = DispatchQueue(label: "com.v2ambition.LogDogCLI.shellQueue")

func shell(command: String,
           outputHandler: @escaping (String) -> Void,
           errorHandler: @escaping (String) -> Void) {
    
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", command]
    
    let makePipe = { (pipeHandler: @escaping (String) -> Void) -> Pipe in
        let pipe = Pipe()
        pipe.fileHandleForReading.readabilityHandler = { handler in
            let data = handler.availableData
            shellQueue.async {
                if let s = String(bytes: data, encoding: .utf8) {
                    pipeHandler(s)
                }
            }
        }
        return pipe
    }

    process.standardOutput = makePipe(outputHandler)
    process.standardError = makePipe(errorHandler)

    try? process.run()

    process.waitUntilExit()
}
