import Foundation
import Combine
import SwiftUI
import PhotosUI

final class ProfileViewModel: ObservableObject {
    @Published var userName: String = "Berber"
    @Published var isEditing: Bool = false
    @Published var totalShaveCount: Int = 0
    @Published var profileImage: UIImage? = nil
    @Published var isLoadingImage: Bool = false
    
    private let userNameKey = "profile_user_name_key"
    private let avatarPathKey = "profile_avatar_path_key"
    private var cancellables = Set<AnyCancellable>()
    
    // Dependency injection için weak reference
    private weak var earningsViewModel: EarningsViewModel?
    
    private var avatarURL: URL? {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
        return caches?.appendingPathComponent("berbers_avatar.jpg")
    }
    
    init() {
        Task {
            await loadUserName()
            await loadProfileImage()
        }
        loadTotalShaveCount()
    }
    
    // MARK: - Editing Methods
    func startEditing() {
        isEditing = true
    }
    
    func cancelEditing() {
        isEditing = false
    }
    
    // MARK: - Data Loading and Saving
    @MainActor
    private func loadUserName() {
        if let saved = UserDefaults.standard.string(forKey: userNameKey), !saved.isEmpty {
            userName = saved
        }
    }
    
    @MainActor
    func saveUserName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        userName = trimmed
        UserDefaults.standard.set(trimmed, forKey: userNameKey)
        isEditing = false
    }
    
    // MARK: - Shave Count Management
    private func loadTotalShaveCount() {
        // EarningsViewModel'i inject etmek için
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.updateShaveCount()
        }
    }
    
    func updateShaveCount() {
        // EarningsViewModel reference'ını bulmaya çalış
        if let earnings = earningsViewModel {
            totalShaveCount = earnings.totalShaveCount
        }
    }
    
    func setEarningsViewModel(_ earningsViewModel: EarningsViewModel) {
        self.earningsViewModel = earningsViewModel
        updateShaveCount()
    }
    
    // MARK: - Profile Image Management
    @MainActor
    private func loadProfileImage() {
        guard let _ = UserDefaults.standard.string(forKey: avatarPathKey),
              let avatarURL = self.avatarURL,
              FileManager.default.fileExists(atPath: avatarURL.path) else {
            return
        }
        
        Task { [weak self] in
            do {
                let data = try Data(contentsOf: avatarURL)
                let image = UIImage(data: data)
                
                await MainActor.run {
                    self?.profileImage = image
                }
            } catch {
                print("Profil resmi yüklenirken hata: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    func saveProfileImage(_ data: Data) {
        guard let avatarURL = self.avatarURL else { return }
        
        isLoadingImage = true
        
        Task { [weak self] in
            do {
                try data.write(to: avatarURL)
                let image = UIImage(data: data)
                
                await MainActor.run {
                    self?.profileImage = image
                    self?.isLoadingImage = false
                    UserDefaults.standard.set(avatarURL.path, forKey: self?.avatarPathKey ?? "")
                }
            } catch {
                await MainActor.run {
                    self?.isLoadingImage = false
                    print("Profil resmi kaydedilirken hata: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func resizeImage(_ image: UIImage, to size: CGSize) async -> UIImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let renderer = UIGraphicsImageRenderer(size: size)
                let resized = renderer.image { _ in
                    image.draw(in: CGRect(origin: .zero, size: size))
                }
                continuation.resume(returning: resized)
            }
        }
    }
    
    // MARK: - Memory Management
    
    deinit {
        cancellables.removeAll()
    }
} 