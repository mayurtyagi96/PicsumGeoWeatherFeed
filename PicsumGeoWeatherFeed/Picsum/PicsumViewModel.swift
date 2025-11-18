import SwiftUI
import Combine

@MainActor
class PicsumViewModel: ObservableObject {
    @Published var listData: [PicsumModel] = []
    @Published var isLoading = false
    @Published var errorMessage: ErrorWrapper?
    
    func getListData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.listData = try await APIService.shared.getPicsumListData()
        } catch {
            errorMessage = ErrorWrapper(message: error.localizedDescription)
        }
        
        isLoading = false
    }
}
