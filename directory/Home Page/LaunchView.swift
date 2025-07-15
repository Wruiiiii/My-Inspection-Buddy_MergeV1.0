//
//  LaunchView.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 7/10/25.
//

import SwiftUI

struct LaunchView: View {
    @State private var scale = 0.7
    @State private var opacity = 0.5

    var body: some View {
        ZStack {
            Image("LaunchBG") // Make sure this name matches your asset
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                // This overlay adds a semi-transparent dark layer, making text more readable.
                // You can adjust the opacity or remove it if you don't need it.
                .overlay(Color.black.opacity(0.3))

            VStack {
                VStack {
                    // Replace "AppLogo" with the name of your image asset
                    Image("Logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 300, height: 300)

                    Text("My Inspection Buddy")
                        .foregroundStyle(.white)
                        .font(.system(size:36))
                        .fontWeight(.bold)
                        .foregroundColor(.primary.opacity(0.8))
                }
                // Apply the animation effects
                .scaleEffect(scale)
                .opacity(opacity)
                // Animate the changes when the view appears
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.8)) {
                        self.scale = 1.0
                        self.opacity = 1.0
                    }
                }
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
