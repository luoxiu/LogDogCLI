import LogDog
import Foundation
import ArgumentParser

let jsonDecoder = JSONDecoder()

enum CLIError: Error {
    case fileNotExists(String)
}

struct CLI: ParsableCommand {
    
    @Argument(help: "Path to the log file")
    var file: String
    
    @Option(name: .shortAndLong, help: "Label to filter")
    var label: String?
    
    @Option(name: .shortAndLong, help: "Keyword to filter")
    var keyword: String?
    
    @Option(name: .shortAndLong, help: "Processor to use")
    var style = "plain"
    
    @Flag(name: .shortAndLong, help: "Color or not")
    var color = true
    
    mutating func run() throws {
        let label = self.label
        let keyword = self.keyword
        let style = self.style
        let color = self.color
        
        shell(
            command: "tail -f \(file)",
            outputHandler: {
                guard let data = $0.data(using: .utf8) else {
                    return
                }
                do {
                    let logEntry = try jsonDecoder.decode(LogEntry.self, from: data)
                    
                    if let label = label {
                        guard logEntry.label == label else {
                            return
                        }
                    }
                    
                    if let keyword = keyword {
                        guard logEntry.message.description.contains(keyword) else {
                            return
                        }
                    }
                    
                    var processor = AnyLogProcessor(
                        TextLogProcessor.preferredFormat(.plain)
                    )
                    
                    if style == "box" {
                        processor = AnyLogProcessor(
                            BoxTextLogProcessor(showDate: true, showThread: true, showLocation: true)
                        )
                    }
                    
                    if color {
                        processor = AnyLogProcessor(
                            processor + ColorLogProcessor()
                        )
                    }
                    
                    let output = try processor.process(logEntry).output
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
