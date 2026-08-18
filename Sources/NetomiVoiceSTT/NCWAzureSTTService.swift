//
//  NCWAzureSTTService.swift
//  NetomiVoiceSTT
//
//  Created by Sandeep on 19/06/25.
//
//  Real Microsoft Speech SDK-backed STT implementation. This is the only file in the
//  SDK that imports MicrosoftCognitiveServicesSpeech. Linking this optional module
//  automatically installs it as the active STT provider (see NCWVoiceSTTActivation.swift).

import Foundation
import MicrosoftCognitiveServicesSpeech
@_spi(NetomiVoiceSTT) import Netomi

internal enum NCWRecognitionReason: Equatable {
    case recognizingSpeech
    case recognizedSpeech
    case canceled
    case noMatch
    case other(String)

    init(spxReason: SPXResultReason) {
        switch spxReason {
        case .recognizingSpeech: self = .recognizingSpeech
        case .recognizedSpeech: self = .recognizedSpeech
        case .canceled: self = .canceled
        case .noMatch: self = .noMatch
        default: self = .other(String(describing: spxReason))
        }
    }
}

internal struct NCWRecognitionResult: Equatable {
    let reason: NCWRecognitionReason
    let text: String?
    let cancellationDetails: String? // optional; used in failure messages if you want
}

internal protocol NCWSpeechRecognizing: AnyObject {
    func addRecognizing(_ handler: @escaping (String?) -> Void)
    func addRecognized(_ handler: @escaping (String?) -> Void)
    func addCanceled(_ handler: @escaping (_ authenticationFailure: Bool, _ details: String?) -> Void)

    func recognizeOnce() throws -> NCWRecognitionResult
    func startContinuousRecognition() throws
    func stopContinuousRecognition() throws
}

internal final class SPXRecognizerAdapter: NCWSpeechRecognizing {
    private let recognizer: SPXSpeechRecognizer

    init(_ recognizer: SPXSpeechRecognizer) {
        self.recognizer = recognizer
    }

    func addRecognizing(_ handler: @escaping (String?) -> Void) {
        recognizer.addRecognizingEventHandler { _, event in
            handler(event.result.text)
        }
    }

    func addRecognized(_ handler: @escaping (String?) -> Void) {
        recognizer.addRecognizedEventHandler { _, event in
            handler(event.result.text)
        }
    }

    func addCanceled(_ handler: @escaping (Bool, String?) -> Void) {
        recognizer.addCanceledEventHandler { _, event in
            if let details = try? SPXCancellationDetails(fromCanceledRecognitionResult: event.result) {
                handler(details.errorCode == .authenticationFailure, details.errorDetails)
            } else {
                handler(false, nil)
            }
        }
    }

    func recognizeOnce() throws -> NCWRecognitionResult {
        let r = try recognizer.recognizeOnce()
        var details: String?
        if r.reason != .recognizedSpeech {
            details = (try? SPXCancellationDetails(fromCanceledRecognitionResult: r))?.errorDetails
        }
        return NCWRecognitionResult(
            reason: NCWRecognitionReason(spxReason: r.reason),
            text: r.text,
            cancellationDetails: details
        )
    }

    func startContinuousRecognition() throws {
        try recognizer.startContinuousRecognition()
    }

    func stopContinuousRecognition() throws {
        try recognizer.stopContinuousRecognition()
    }
}

internal typealias NCWRecognizerFactory = (_ token: String, _ region: String, _ voiceConfig: NCWVoiceConfig?) throws -> NCWSpeechRecognizing

internal final class NCWAzureSTTService: NCWSpeechToTextService {
    private let voiceConfig: NCWVoiceConfig?
    private let tokenManager: NCWSpeechTokenProvider
    private let recognizerFactory: NCWRecognizerFactory

    private var cachedRecognizer: NCWSpeechRecognizing?
    private var isRecognizing = false
    private var completionHandler: ((Result<NCWSTTResult, NCWVoiceIOError>) -> Void)?
    private var voiceInputStream: String?
    private var isCancelled = false

    init(voiceConfig: NCWVoiceConfig?,
         tokenManager: NCWSpeechTokenProvider = NCWSpeechTokenManager.shared,
         recognizerFactory: @escaping NCWRecognizerFactory = NCWAzureSTTService.defaultRecognizerFactory) {
        self.voiceConfig = voiceConfig
        self.tokenManager = tokenManager
        self.recognizerFactory = recognizerFactory

        Task { [weak self] in
            _ = try? await self?.createRecognizer()
        }
    }

    // MARK: - Async Single-shot Recognition
    func recognizeOnce(completion: @escaping (Result<NCWSTTResult, NCWVoiceIOError>) -> Void) {
        Task {[weak self] in
            guard let self else { return }
            do {
                self.isCancelled = false
                let recognizer = try await createRecognizer()
                self.isRecognizing = true
                self.completionHandler = completion

                // Inform UI: ready to transcribe
                completion(.success(NCWSTTResult(isTranscribing: true)))

                // Live partial updates
                recognizer.addRecognizing { [weak self] in self?.handleSingleShotPartial($0) }

                // Final result
                let result = try recognizer.recognizeOnce()
                self.handleSingleShotResult(result, completion: completion)
            } catch {
                self.handleSetupError(error, completion: completion)
            }
        }
    }

    private func handleSingleShotPartial(_ text: String?) {
        guard isRecognizing, !isCancelled else { return }
        let partial = text ?? ""
        voiceInputStream = partial
        completionHandler?(.success(NCWSTTResult(text: partial)))
    }

    private func handleSingleShotResult(
        _ result: NCWRecognitionResult,
        completion: @escaping (Result<NCWSTTResult, NCWVoiceIOError>) -> Void
    ) {
        guard !isCancelled else {
            finishRecognition(with: .failure(.cancelled))
            return
        }
        guard result.reason == .recognizedSpeech else {
            finishRecognition(with: .failure(.sttRecognitionFailed(reason: result.cancellationDetails ?? "No details")))
            return
        }
        completion(.success(NCWSTTResult(text: result.text ?? "", isFinal: true)))
    }

    // MARK: - Continuous Recognition
    func recognizeContinuously(completion: @escaping (Result<NCWSTTResult, NCWVoiceIOError>) -> Void) {
        Task {[weak self] in
            guard let self else { return }
            do {
                self.isCancelled = false
                let recognizer = try await self.createRecognizer()
                self.completionHandler = completion
                self.isRecognizing = true

                // Inform UI: ready to transcribe
                completion(.success(NCWSTTResult(isTranscribing: true)))

                recognizer.addRecognizing { [weak self] in self?.handleContinuousPartial($0) }
                recognizer.addRecognized { [weak self] in self?.handleContinuousRecognized($0) }
                recognizer.addCanceled { [weak self] authFailure, _ in
                    self?.handleContinuousCanceled(authFailure: authFailure)
                }

                try recognizer.startContinuousRecognition()
            } catch {
                self.handleSetupError(error, completion: completion)
            }
        }
    }

    private func handleContinuousPartial(_ text: String?) {
        guard isRecognizing, !isCancelled else { return }
        let partialText = text ?? ""
        guard !partialText.isEmpty else { return }
        let newText = appendSmartly(to: voiceInputStream, newText: partialText)
        voiceInputStream = newText
        completionHandler?(.success(NCWSTTResult(text: newText)))
    }

    private func handleContinuousRecognized(_ text: String?) {
        guard isRecognizing, !isCancelled else { return }

        var newText = voiceInputStream ?? ""
        if newText.isEmpty {
            newText = text ?? ""
        }
        completionHandler?(.success(NCWSTTResult(text: newText, isFinal: true)))
    }

    private func handleContinuousCanceled(authFailure: Bool) {
        guard isRecognizing, !isCancelled else { return }
        if authFailure {
            retryRecognitionAfterTokenRefresh()
        } else {
            finishRecognition(with: .failure(.cancelled))
        }
    }

    /// Maps a setup/recognition error onto the completion handler and cleans up.
    /// `NCWVoiceIOError`s are forwarded as-is; anything else is wrapped.
    private func handleSetupError(
        _ error: Error,
        completion: @escaping (Result<NCWSTTResult, NCWVoiceIOError>) -> Void
    ) {
        if let voiceError = error as? NCWVoiceIOError {
            completion(.failure(voiceError))
        } else {
            finishRecognition(with: .failure(.sttRecognitionFailed(reason: error.localizedDescription)))
        }
        cleanup(keepCancellation: true)
    }

    func cancel() async {
        guard isRecognizing, !isCancelled else { return }
        isCancelled = true
        finishRecognition(with: .failure(.cancelled))
    }

    func disconnect() async {
        await cancel()
    }

    @discardableResult
    private func createRecognizer() async throws -> NCWSpeechRecognizing {
        guard self.voiceConfig?.isEnabled == true else {
            throw NCWVoiceIOError.disabled
        }

        let response = await tokenManager.fetchTokenAsync()

        guard let token = response?.token, let region = response?.region,
              !token.isEmpty else {
            throw NCWVoiceIOError.sttRecognitionFailed(reason: "Failed to fetch Azure token")
        }

        let r = try recognizerFactory(token, region, voiceConfig)
        self.cachedRecognizer = r
        return r
    }

    private func appendSmartly(to original: String?, newText: String) -> String {
        let trimmedOriginal = original?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let needsSpace = !trimmedOriginal.isEmpty && !trimmedOriginal.hasSuffix(" ")
        return trimmedOriginal + (needsSpace ? " " : "") + newText
    }

    private func finishRecognition(with result: Result<String, NCWVoiceIOError>) {
        guard isRecognizing else { return }

        try? cachedRecognizer?.stopContinuousRecognition()
        let wrappedResult: Result<NCWSTTResult, NCWVoiceIOError> = result.map {
            NCWSTTResult(text: $0, isFinal: true)
        }
        completionHandler?(wrappedResult)
        cleanup(keepCancellation: true)
    }

    private func retryRecognitionAfterTokenRefresh() {
        Task {[weak self] in
            guard let self else { return }
            do {
                self.cachedRecognizer = nil
                try await createRecognizer()

                // Rebind the handlers
                self.recognizeContinuously(completion: self.completionHandler ?? { _ in })
            } catch {
                self.finishRecognition(with: .failure(.sttRecognitionFailed(reason: "Failed after retry: \(error.localizedDescription)")))
            }
        }
    }

    private func cleanup(keepCancellation: Bool = false) {
        cachedRecognizer = nil
        completionHandler = nil
        isRecognizing = false
        voiceInputStream = nil
        if !keepCancellation {
            isCancelled = false
        }
    }

    deinit {
        try? cachedRecognizer?.stopContinuousRecognition()
    }
}

private extension NCWAzureSTTService {
    static let defaultLanguageCode = "en-US"

    static func defaultRecognizerFactory(
        token: String,
        region: String,
        voiceConfig: NCWVoiceConfig?
    ) throws -> NCWSpeechRecognizing {
        let speechConfig = try SPXSpeechConfiguration(authorizationToken: token, region: region)
        speechConfig.speechRecognitionLanguage = resolvedLanguageCode(from: voiceConfig)

        let spx = try makeRecognizer(speechConfig: speechConfig, voiceConfig: voiceConfig)
        applyPhraseList(voiceConfig?.phraseList, to: spx)
        return SPXRecognizerAdapter(spx)
    }

    static func resolvedLanguageCode(from voiceConfig: NCWVoiceConfig?) -> String {
        let trimmed = voiceConfig?.langCode?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed ?? defaultLanguageCode
    }

    static func makeRecognizer(
        speechConfig: SPXSpeechConfiguration,
        voiceConfig: NCWVoiceConfig?
    ) throws -> SPXSpeechRecognizer {
        let audioConfig = SPXAudioConfiguration()
        let autoDetectLanguages = voiceConfig?.azureAutoDetectLanguages?
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty } ?? []

        guard !autoDetectLanguages.isEmpty else {
            return try SPXSpeechRecognizer(
                speechConfiguration: speechConfig,
                language: defaultLanguageCode,
                audioConfiguration: audioConfig
            )
        }

        let auto = try SPXAutoDetectSourceLanguageConfiguration(autoDetectLanguages)
        return try SPXSpeechRecognizer(
            speechConfiguration: speechConfig,
            autoDetectSourceLanguageConfiguration: auto,
            audioConfiguration: audioConfig
        )
    }

    static func applyPhraseList(_ phrases: [String]?, to recognizer: SPXSpeechRecognizer) {
        guard let phrases, !phrases.isEmpty,
              let grammar = SPXPhraseListGrammar(recognizer: recognizer) else { return }
        phrases.forEach { grammar.addPhrase($0) }
    }
}
