import SwiftUI

struct ServicesView: View {
    @EnvironmentObject private var viewModel: ServicesViewModel
    @State private var newTitle: String = ""
    @State private var newPrice: String = ""
    @FocusState private var priceFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            VStack {
                if viewModel.services.isEmpty {
                    Spacer()
                    Text("Henüz bir hizmet eklenmedi.")
                        .foregroundColor(.secondary)
                        .font(.body)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.services) { service in
                                ServiceCard(
                                    service: service,
                                    onEdit: {
                                        newTitle = service.title
                                        newPrice = String(Int(service.price))
                                        viewModel.presentEditAlert(for: service)
                                    },
                                    onDelete: {
                                        viewModel.requestDeleteService(service)
                                    }
                                )
                            }
                        }
                        .padding(.top, 16)
                    }
                }
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "plus") {
                        newTitle = ""
                        newPrice = ""
                        viewModel.presentAddAlert()
                    }
                    .padding([.bottom, .trailing], 24)
                }
            }
        }
        // Alert for Delete Confirmation
        .alert("Hizmet Sil", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Evet", role: .destructive) {
                viewModel.confirmDeleteService()
            }
            Button("Hayır", role: .cancel) {
                viewModel.cancelDeleteService()
            }
        } message: {
            Text("Bu hizmeti silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        // Alert for Add/Edit
        .alert(viewModel.editingService == nil ? "Yeni Hizmet Ekle" : "Hizmeti Güncelle", isPresented: $viewModel.alertPresented) {
            TextField("Hizmet Adı", text: $newTitle)
            TextField("Fiyat", text: $newPrice)
                .keyboardType(.decimalPad)
                .focused($priceFieldFocused)
            Button(viewModel.editingService == nil ? "Ekle" : "Güncelle") {
                guard let price = Double(newPrice.replacingOccurrences(of: ",", with: ".")), !newTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                if let editing = viewModel.editingService {
                    viewModel.updateService(editing, newTitle: newTitle, newPrice: price)
                } else {
                    viewModel.addService(title: newTitle, price: price)
                }
                viewModel.dismissAlert()
            }
            Button("İptal", role: .cancel) {
                viewModel.dismissAlert()
            }
        } message: {
            Text("Lütfen hizmet adı ve fiyatı giriniz.")
        }
        .onAppear {
            // Performans: Sadece görünür olduğunda veri yükle
            viewModel.loadServices()
        }
    }
}

#if DEBUG
struct ServicesView_Previews: PreviewProvider {
    static var previews: some View {
        ServicesView()
            .environmentObject(ServicesViewModel())
    }
}
#endif 