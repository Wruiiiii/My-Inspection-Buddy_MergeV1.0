import SwiftUI

struct PhotoAlbumView: View {
    @State private var inputImage: UIImage?
    
    @State private var showingCamera = false
    @State private var showingPhotoLibrary = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            Text("Select a photo to begin detection.")
                .font(.headline)
                .foregroundColor(.secondary)

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
                
                if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxHeight: .infinity)

            HStack(spacing: 15) {
                Button(action: {
                    self.showingPhotoLibrary = true
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Select Photo")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
                }
                
                Button(action: {
                    self.showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                        Text("Take Photo")
                    }
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray5))
                    .foregroundColor(.accentColor)
                    .cornerRadius(10)
                }
            }
            
            if inputImage != nil {
                Button(action: {
                    // TODO: Add your actual device detection logic here.
                    print("Performing detection on the selected image...")
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Detect Device in Selected Photo")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .navigationTitle("Device Detection")
        .sheet(isPresented: $showingCamera) {
            ImagePicker(sourceType: .camera, image: $inputImage)
        }
        .sheet(isPresented: $showingPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary, image: $inputImage)
        }
    }
}
