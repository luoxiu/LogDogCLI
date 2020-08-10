import LogDog
import Foundation
import ArgumentParser

Loggers.setUp()

let jsonDecoder = JSONDecoder()

enum CLIError: Error {
    case fileNotExists(String)
}

struct CLI: ParsableCommand {
    
    @Argument(help: "Path to the log file")
    var file: String
    
    @Option(name: .shortAndLong, help: "Label to filter")
    var label: String?
    
    mutating func run() throws {
        shell(
            command: "tail -f \(file)",
            outputHandler: {
                guard let data = $0.data(using: .utf8) else {
                    return
                }
                do {
                    let logEntry = try jsonDecoder.decode(LogEntry.self, from: data)
                    
                    guard logEntry.label == self.label else {
                        return
                    }
                    
                    let processor = BoxedTextLogProcessor() + ColorLogProcessor()
                    let output = try processor.process(ProcessedLogEntry(logEntry, ())).output
                    print(output)
                } catch {
                    print(error)
                }
            },
            errorHandler: {
                print($0)
            }
        )
    }
}

CLI.main()
