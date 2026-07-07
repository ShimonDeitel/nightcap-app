import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showAddSheet = false
    @State private var showSettings = false
    @State private var showPaywall = false
    @State private var editingEntry: CocktailEntry?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background.ignoresSafeArea()
                List {
                    ForEach(store.entries) { entry in
                        Button {
                            editingEntry = entry
                        } label: {
                            EntryRow(entry: entry)
                        }
                        .accessibilityIdentifier("entryRow_\(entry.name)")
                        .listRowBackground(Theme.cardBackground)
                    }
                    .onDelete { offsets in
                        store.delete(at: offsets)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
            .navigationTitle("Nightcap")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAddMore {
                            showAddSheet = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("addButton")
                }
            }
            .sheet(isPresented: $showAddSheet) {
                EntryFormView(mode: .add)
            }
            .sheet(item: $editingEntry) { entry in
                EntryFormView(mode: .edit(entry))
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
        .accentColor(Theme.accent)
    }
}

struct EntryRow: View {
    let entry: CocktailEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.name)
                .font(Theme.headlineFont)
                .foregroundColor(Theme.textPrimary)
            Text("Recipe: \(entry.recipe)  ·  Venue/Home: \(entry.venue)")
                .font(.caption)
                .foregroundColor(Theme.textSecondary)
            Text("Rating: \(entry.rating)")
                .font(.caption)
                .foregroundColor(Theme.accent)
        }
        .padding(.vertical, 4)
    }
}

enum FormMode: Equatable {
    case add
    case edit(CocktailEntry)
}

struct EntryFormView: View {
    @EnvironmentObject var store: Store
    @Environment(\.dismiss) var dismiss
    let mode: FormMode

    @State private var name: String = ""
    @State private var f1: String = ""
    @State private var f2: String = ""
    @State private var f3: String = ""

    init(mode: FormMode) {
        self.mode = mode
        if case .edit(let entry) = mode {
            _name = State(initialValue: entry.name)
            _f1 = State(initialValue: entry.recipe)
            _f2 = State(initialValue: entry.venue)
            _f3 = State(initialValue: entry.rating)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("nameField")
                    TextField("Recipe", text: $f1)
                        .accessibilityIdentifier("f1Field")
                    TextField("Venue/Home", text: $f2)
                        .accessibilityIdentifier("f2Field")
                    TextField("Rating", text: $f3)
                        .accessibilityIdentifier("f3Field")
                }
                if case .edit(let entry) = mode {
                    Section {
                        Button("Delete", role: .destructive) {
                            store.delete(entry)
                            dismiss()
                        }
                        .accessibilityIdentifier("deleteButton")
                    }
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .contentShape(Rectangle())
            .onTapGesture {
                hideKeyboard()
            }
            .navigationTitle(mode == .add ? "Add Cocktail" : "Edit Cocktail")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelButton")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                    .accessibilityIdentifier("saveButton")
                }
            }
        }
    }

    private func save() {
        switch mode {
        case .add:
            store.add(name: name, f1: f1, f2: f2, f3: f3)
        case .edit(var entry):
            entry.name = name
            entry.recipe = f1
            entry.venue = f2
            entry.rating = f3
            store.update(entry)
        }
        dismiss()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
