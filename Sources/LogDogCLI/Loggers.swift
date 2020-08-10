import LogDog

enum Loggers {
    static func setUp() {
        LoggingSystem.bootstrap { label -> LogHandler in
            let outputStream = StdoutLogOutputStream()
            let processor = TextLogProcessor.preferredFormat(.emoji)
            return LogDogLogHandler(label: label, processor: processor, outputStream: outputStream)
        }
    }
    
    static let cli = Logger(label: "cli")
    
    static let dev = Logger(label: "dev")
}
