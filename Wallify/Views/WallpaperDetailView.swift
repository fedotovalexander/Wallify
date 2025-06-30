//
//  WalpaperDetailView.swift
//  Wallify
//
//  Created by Alexander Fedotov on 6/30/25.
//

import SwiftUI

struct WallpaperDetailView: View {
    let image: UnsplashImage
    @State private var uiImage: UIImage?
    @State private var isLoading = true
    @State private var showShareSheet = false
    @State private var showSavedAlert = false
    
    var body: some View {
        VStack {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 500)
            } else {
                ProgressView()
                    .padding()
            }

            HStack(spacing: 20) {
                Button("Сохранить в Фото") {
                    saveToPhotos()
                }
                .buttonStyle(.borderedProminent)

                Button("Поделиться") {
                    showShareSheet = true
                }
                .buttonStyle(.bordered)
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Обои")
        .task {
            await loadFullImage()
        }
        .sheet(isPresented: $showShareSheet) {
            if let uiImage {
                ShareSheet(activityItems: [uiImage])
            }
        }
        .alert("Изображение сохранено", isPresented: $showSavedAlert) {
            Button("ОК", role: .cancel) { }
        }
    }

    func loadFullImage() async {
        guard let url = URL(string: image.urls.full) else { return }
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                self.uiImage = image
            }
        } catch {
            print("Ошибка загрузки изображения: \(error.localizedDescription)")
        }
        isLoading = false
    }

    func saveToPhotos() {
        guard let image = uiImage else { return }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        showSavedAlert = true
    }
}


#Preview {
    WallpaperDetailView()
}
