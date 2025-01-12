import Fluent
import Vapor

struct TodoDTO: Content {
    var title: String?
    
    func toModel() -> Todo {
        let model = Todo()
        
        model.id = UUID()
        if let title = self.title {
            model.title = title
        }
        return model
    }
}
