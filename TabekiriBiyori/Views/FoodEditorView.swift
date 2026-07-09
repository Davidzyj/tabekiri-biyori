import SwiftUI
import SwiftData
import PhotosUI

struct FoodEditorView: View {
    enum Field: Hashable { case name, note }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var name: String
    @State private var expiryDate: Date
    @State private var expiryKind: ExpiryKind
    @State private var storage: StoragePlace
    @State private var note: String
    @State private var imageData: Data?
    @State private var photoItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var showingSourceMenu = false
    @State private var scanMessageKey: String?
    @State private var isScanning = false
    @FocusState private var focusedField: Field?

    private let item: FoodItem?
    private let onSaved: () -> Void

    init(item: FoodItem? = nil, onSaved: @escaping () -> Void = {}) {
        self.item = item
        self.onSaved = onSaved
        _name = State(initialValue: item?.name ?? "")
        _expiryDate = State(initialValue: item?.expiryDate ?? Calendar.current.date(byAdding: .day, value: 3, to: .now)!)
        _expiryKind = State(initialValue: item?.expiryKind ?? .bestBefore)
        _storage = State(initialValue: item?.storage ?? .fridge)
        _note = State(initialValue: item?.note ?? "")
        _imageData = State(initialValue: item?.photoData)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 18) {
                        imageSection
                        fieldCard
                        scanCard
                    }
                    .padding(20)
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle(item == nil ? "editor_add_title" : "editor_edit_title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("cancel") { focusedField = nil; dismiss() }
                        .foregroundStyle(AppTheme.secondaryInk)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("save") { save() }
                        .fontWeight(.semibold)
                        .foregroundStyle(canSave ? AppTheme.accent : Color(red: 0.48, green: 0.46, blue: 0.42))
                        .disabled(!canSave)
                        .accessibilityIdentifier("saveFoodButton")
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("keyboard_done") { focusedField = nil }
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .confirmationDialog("scan_source_title", isPresented: $showingSourceMenu) {
                Button("scan_camera") { showingCamera = true }
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Text("scan_library")
                }
                Button("cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showingCamera) {
                CameraPicker { image in
                    imageData = image.jpegData(compressionQuality: 0.78)
                    runRecognition(image)
                }
                .ignoresSafeArea()
            }
            .onChange(of: photoItem) { _, newValue in
                guard let newValue else { return }
                Task {
                    if let data = try? await newValue.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        imageData = image.jpegData(compressionQuality: 0.78)
                        runRecognition(image)
                    }
                }
            }
        }
        .preferredColorScheme(.light)
    }

    private var imageSection: some View {
        Group {
            if let imageData, let image = UIImage(data: imageData) {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image).resizable().scaledToFill()
                        .frame(height: 160).frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                    Button {
                        self.imageData = nil
                    } label: {
                        Image(systemName: "xmark").foregroundStyle(.white)
                            .padding(9).background(AppTheme.ink.opacity(0.82), in: Circle())
                    }
                    .padding(10)
                }
            }
        }
    }

    private var fieldCard: some View {
        VStack(spacing: 0) {
            TextField("", text: $name, prompt: Text("food_name_placeholder").foregroundStyle(Color(red: 0.43, green: 0.41, blue: 0.37)))
                .focused($focusedField, equals: .name)
                .submitLabel(.next)
                .onSubmit { focusedField = .note }
                .foregroundStyle(AppTheme.ink)
                .padding(16)
                .accessibilityIdentifier("foodNameField")
            Divider().overlay(AppTheme.divider)
            DatePicker("expiry_date", selection: $expiryDate, displayedComponents: .date)
                .foregroundStyle(AppTheme.ink).padding(16)
            Divider().overlay(AppTheme.divider)
            Picker("expiry_kind", selection: $expiryKind) {
                ForEach(ExpiryKind.allCases) { kind in Text(LocalizedStringKey("expiry_\(kind.rawValue)")).tag(kind) }
            }
            .foregroundStyle(AppTheme.ink).padding(16)
            Divider().overlay(AppTheme.divider)
            Picker("storage_place", selection: $storage) {
                ForEach(StoragePlace.allCases) { place in Text(LocalizedStringKey("storage_\(place.rawValue)")).tag(place) }
            }
            .foregroundStyle(AppTheme.ink).padding(16)
            Divider().overlay(AppTheme.divider)
            TextField("", text: $note, prompt: Text("note_placeholder").foregroundStyle(Color(red: 0.43, green: 0.41, blue: 0.37)), axis: .vertical)
                .focused($focusedField, equals: .note)
                .lineLimit(2...4)
                .foregroundStyle(AppTheme.ink)
                .padding(16)
        }
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.divider.opacity(0.55)))
    }

    private var scanCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                focusedField = nil
                showingSourceMenu = true
            } label: {
                HStack {
                    Image(systemName: "viewfinder")
                    Text(isScanning ? "scanning" : "scan_date")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(AppTheme.ink)
            }
            .disabled(isScanning)
            if let scanMessageKey {
                Text(LocalizedStringKey(scanMessageKey))
                    .font(.caption)
                    .foregroundStyle(scanMessageKey == "scan_success" ? AppTheme.leaf : AppTheme.accent)
            }
            Text("scan_privacy_note").font(.caption).foregroundStyle(AppTheme.secondaryInk)
        }
        .padding(18)
        .background(AppTheme.surface, in: RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AppTheme.divider.opacity(0.55)))
    }

    private var canSave: Bool { !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

    private func runRecognition(_ image: UIImage) {
        isScanning = true
        scanMessageKey = nil
        Task {
            do {
                expiryDate = try await DateRecognitionService.recognizeDate(in: image)
                scanMessageKey = "scan_success"
            } catch {
                scanMessageKey = "scan_failed"
            }
            isScanning = false
        }
    }

    private func save() {
        focusedField = nil
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        if let item {
            item.name = trimmed
            item.expiryDate = Calendar.current.startOfDay(for: expiryDate)
            item.expiryKind = expiryKind
            item.storage = storage
            item.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
            item.photoData = imageData
            item.updatedAt = .now
        } else {
            modelContext.insert(FoodItem(
                name: trimmed,
                expiryDate: expiryDate,
                expiryKind: expiryKind,
                storage: storage,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines),
                photoData: imageData
            ))
        }
        try? modelContext.save()
        onSaved()
        dismiss()
    }
}
