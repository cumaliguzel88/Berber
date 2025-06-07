import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject private var viewModel: AppointmentsViewModel
    @EnvironmentObject private var servicesViewModel: ServicesViewModel
    @State private var showEditSheet: Bool = false
    @State private var editingAppointment: Appointment? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(.systemBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                HorizontalCalendar(selectedDate: $viewModel.selectedDate)
                Divider()
                if viewModel.appointmentsForSelectedDate.isEmpty {
                    Spacer()
                    Text("Bu gün için randevu yok.")
                        .foregroundColor(.secondary)
                        .font(.body)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(viewModel.appointmentsForSelectedDate) { appointment in
                                AppointmentCard(
                                    appointment: appointment,
                                    onDelete: {
                                        viewModel.requestDeleteAppointment(appointment)
                                    },
                                    onEdit: {
                                        editingAppointment = appointment
                                        showEditSheet = true
                                    }
                                )
                            }
                        }
                        .padding(.top, 12)
                    }
                }
            }
            FloatingActionButton(icon: "plus") {
                viewModel.showBottomSheet = true
            }
            .padding(.bottom, 24)
            .padding(.trailing, 24)
        }
        .sheet(isPresented: $viewModel.showBottomSheet) {
            AddAppointmentSheet(
                isPresented: $viewModel.showBottomSheet,
                services: servicesViewModel.services,
                onAdd: { name, service, duration, startDate in
                    return viewModel.addAppointment(customerName: name, service: service, duration: duration, startDate: startDate)
                },
                selectedDate: viewModel.selectedDate
            )
        }
        .sheet(isPresented: $showEditSheet) {
            Group {
                if let editing = editingAppointment {
                    AddAppointmentSheet(
                        isPresented: $showEditSheet,
                        services: servicesViewModel.services,
                        onAdd: { name, service, duration, startDate in
                            viewModel.updateAppointment(editing, newName: name, newService: service, newDuration: duration, newStartDate: startDate)
                            return (true, nil)
                        },
                        initialName: editing.customerName,
                        initialService: editing.service,
                        initialDuration: editing.duration,
                        initialStartDate: editing.startDate,
                        selectedDate: editing.startDate
                    )
                } else {
                    Text("Randevu bilgileri yüklenemedi.")
                        .padding()
                        .onAppear {
                            showEditSheet = false
                        }
                }
            }
        }
        .alert("Randevu Sil", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Evet", role: .destructive) {
                viewModel.confirmDeleteAppointment()
            }
            Button("Hayır", role: .cancel) {
                viewModel.cancelDeleteAppointment()
            }
        } message: {
            Text("Bu randevuyu silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.")
        }
        .onChange(of: showEditSheet) { _, isShowing in
            if !isShowing {
                editingAppointment = nil
            }
        }
        .onAppear {
            viewModel.updateCompletionStatuses()
        }
    }
}

#if DEBUG
struct AppointmentsView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentsView()
            .environmentObject(AppointmentsViewModel())
            .environmentObject(ServicesViewModel())
    }
}
#endif 