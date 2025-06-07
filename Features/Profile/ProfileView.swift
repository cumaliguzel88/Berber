import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel
    @State private var editedName: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showPhotoPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer(minLength: 40)
            profileImageSection
            userNameSection
            shaveCountSection
            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(.systemBackground).ignoresSafeArea())
        .navigationTitle("Profil")
        .onChange(of: selectedPhoto) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    viewModel.saveProfileImage(data)
                }
            }
        }
        .sheet(isPresented: $showPhotoPicker) {
            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                VStack {
                    Label("Fotoğraf Seç", systemImage: "photo")
                        .font(.title3)
                        .padding()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
        }
    }
    
    private var profileImageSection: some View {
        ZStack(alignment: .bottomTrailing) {
            Group {
                if let image = viewModel.profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.square.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.accentColor.opacity(0.5))
                }
            }
            .frame(width: 140, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            // Fotoğraf düzenleme ikonu
            Button(action: {
                showPhotoPicker = true
            }) {
                Image(systemName: "pencil.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.accentColor)
                    .background(
                        Circle().fill(Color(.systemBackground))
                            .frame(width: 40, height: 40)
                    )
                    .offset(x: 8, y: 8)
            }
            .accessibilityLabel("Profil fotoğrafını düzenle")
        }
        .padding(.bottom, 8)
    }
    
    private var userNameSection: some View {
        HStack(spacing: 8) {
            if viewModel.isEditing {
                TextField("Adınızı girin", text: $editedName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: 180)
                Button(action: {
                    let trimmed = editedName.trimmingCharacters(in: .whitespaces)
                    if !trimmed.isEmpty {
                        viewModel.saveUserName(trimmed)
                    } else {
                        viewModel.cancelEditing()
                    }
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                Button(action: {
                    viewModel.cancelEditing()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            } else {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.semibold)
                Button(action: {
                    editedName = viewModel.userName
                    viewModel.startEditing()
                }) {
                    Image(systemName: "pencil")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
    
    private var shaveCountSection: some View {
        Text("Toplam tıraş edilen kişi: \(viewModel.totalShaveCount)")
            .font(.body)
            .foregroundColor(.secondary)
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
#endif 