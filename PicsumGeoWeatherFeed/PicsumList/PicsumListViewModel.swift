//
//  PicsumListViewModel.swift
//  PicsumGeoWeatherFeed
//
//  Created by Mayur on 16/11/25.
//
import SwiftUI
import Combine

@MainActor
class PicsumListViewModel: ObservableObject {
    @Published var listData: [PicsumModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func getListData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.listData = try await APIService.shared.getPicsumListData()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
