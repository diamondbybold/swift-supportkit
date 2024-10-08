# Swift SupportKit

## Overview

Every great software has a great foundation. Swift SupportKit is a foundation for every Swift / SwiftUI project that uses remote data and needs unified and flexible navigation. Also includes extensions and components to make our day more easy and productive.

Like Apple technologies, SupportKit package is splitted into two frameworks:

- **SupportKit** (Non-UI objects)
- **SupportKitUI** (UI objects)

And following platform software design patterns.

## Use Cases

Imagine a shopping app where the user can browse products, browse related products of a product, read product reviews, add product review, ...

###### API endpoints:

```
 GET /products
 GET /products/{id}
 GET /products/{id}/relatedProducts
 GET /products/{id}/reviews
POST /products/{id}/reviews
```

###### Product contract:

```swift
import Foundation

struct Product: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let currencyCode: String
    let image: URL?
}

// MARK: - Derived Properties
extension Product {
    var formattedPrice: String { price.formatted(.currency(code: currencyCode)) }
}

// MARK: - Support Types
extension Product {
    struct Review: Identifiable, Codable {
        let id: String
        let rating: Int
        let comment: String
        let author: String
    }
}
```

###### Simple Request Example

```swift
do {
    // Define url or request object
    let url = URL(string: "https://api.dev.myshopping.com/products")!
    // Request data and response
    let (data, response) = try await URLSession.shared.data(from: url)
    // Decode json
    products = try JSONDecoder().decode([Product].self, from: data)
} catch {
    // Error handling
}
```

### Implementing API client

API client object is a central point for a web service access, handling configuration, environments and inspect every request / response.

```swift
import Foundation
import SupportKit

class MyShoppingAPIClient: APIClient {
    static let shared = MyShoppingAPIClient()
    
#if DEVELOPMENT
    let baseURL = URL(string: "https://api.dev.myshopping.com")!
#elseif QA
    let baseURL = URL(string: "https://api.qa.myshopping.com")!
#else
    let baseURL = URL(string: "https://api.myshopping.com")!
#endif
    
    let version: String? = "v1"
    let session: URLSession = .defaultJSONAPI
    
    func willSendRequest(_ request: inout APIRequest) async throws {        
        // e.g. Handle authorization token and other header things
    }
    
    func didReceiveResponse(_ response: inout APIResponse) async throws {
        // e.g. Handle refresh token and other errors
    }
}
```

### Fetching products

```swift
// MARK: - Fetching products
extension Product {
    static func products(query: String = "") async throws -> [Product] {
        // 1) Make a request, we have other params for method, query string, body payload, form data, ...
        let request = APIRequest(path: "products", query: ["query": query])
        
        // 2) Get the response on an API client
        let response = try await request.response(on: MyShoppingAPIClient.shared)
        
        // 3) Handle respose data or error, SupportKit includes default common status codes, rest resources, jsonapi container, paging, ...
        return try response.resource(.snakeCase)
    }
    
    var relatedProducts: [Product] {
        get await throws {
            try await APIRequest(path: "products/\(id)/relatedProducts")
                .response(on: MyShoppingAPIClient.shared)
                .resource(.snakeCase)
        }
    }
}
```

###### Example

```swift
let products = try await Product.products()
```

```swift
let relatedProducts = try await product.relatedProducts
```

### Fetching product reviews

```swift
// MARK: - Fetching products reviews
extension Product {
    var reviews: [Product.Review] {
        get await throws {
            try await APIRequest(path: "products/\(id)/reviews")
                .response(on: MyShoppingAPIClient.shared)
                .resource(.snakeCase)
        }
    }
}
```

###### Example

```swift
let reviews = try await product.reviews
```

### Sending a product review

```swift
// MARK: - Sending a review
extension Product {
    func sendReview(rating: Int, comment: String) async throws {
        try await APIRequest(path: "products/\(id)/reviews",
                            method: .post,
                            body: .formData(["rating": "\(rating)",
                                            "comment": comment]))
            .response(on: MyShoppingAPIClient.shared)
            .verify()
    }
}
```

###### Example

```swift
try await product.sendReview(rating: 4, text: "Amazing!")
```

### Display products

```swift
import SwiftUI

struct ProductList: View {
    @State private var products: [Product] = []

    var body {
        ScrollView {
            ForEach(products) { product in
                ProductRow(product)
            }
        }
        .task {
            do {
                products = try await Product.products()
            } catch {
                // Error handling
            }
        }
        .navigationTitle("Products")
    }
}
```

### Preparing the app for SupportKit navigation capabilities

NavigationContext is an object responsive for the state of navigation. NavigationContainer is a container View that configures a NavigationStack to use the NavigationContext. We should use .navigationContainer() on every root element of a stack or a modal. Any View in hierarchy can access NavigationContext using @EnvironmentObject.

```swift
import SwiftUI
import SupportKitUI

@main
struct ShoppingApp: App {
    var body: some Scene {
        WindowGroup {
            ProductList()
                .navigationContainer() // Embeds ProductList as root of a NavigationStack with NavigationContext capabilities
        }
    }
}
```

![navigation-context](https://github.com/diamondbybold/swift-supportkit/assets/20373652/f32980eb-777e-4160-990f-5f7a1b02c173)

Included buttons that uses **NavigationContext**:

- **NavigationButton** (possible destinations: stack, sheet, fullscreen cover)
- **PopoverButton**
- **DismissButton** (dismiss the view)
- **DismissContainerButton** (dismiss the container)
- **AlertButton**
- **ConfirmationButton**
- **AsyncButton** (to present alert on task error)

NavigationButton is a button with navigation capabilities, uses NavigationContext.

### Display products

For convenience theres two property wrappers, ResourceRequest and CollectionRequest, like Store, conforming **FetchableObject** protocol. In alternative and for more flexibility we can create a "ProductStore" object conforming **FetchableObject** protocol if needed. And don't forget other model objects like e.g. UserSession, ShoppingCart, CheckoutProcess, ChatSession, UserRegistration, ReviewProduct, ... remember **UI = f(State)** where State = Model

```swift
import SwiftUI
import SupportKit
import SupportKitUI

struct ProductList: View {
    @State private var query: String = ""
    
    @CollectionRequest
    private var products: [Product]

    var body {
        AsyncView(_products) { phase in
            switch phase {
            case .loading:
                ProgressView()
            case .loaded:
                ScrollView {
                    LazyVStack {
                        ForEach(products) { product in
                            productRow(product)
                        }
                        
                        // Infinite scrolling
                        if _products.hasMoreContent {
                            ProgressView()
                                .fetchMoreContent(_products)
                        }
                    }
                }
            case .empty:
                Text("No products")
            case let .error(error):
                Text("Error \(error.localizedDescription)")
                    .onTapGesture {
                        _products.refetch() // Try again
                    }
            }
        }
        .fetch(_products, refetchTrigger: query, refetchDebounce: true) { page in
            try await Product.products(query: query, page: page)
        }
        .refreshable(_products) // Pull down to refresh
        .searchable(text: $query) // Enable search bar
        .navigationTitle("Products")
    }
}

// MARK: - Components
extension ProductList {
    func productRow(_ product: Product) -> some View {
        NavigationButton(destination: .stack) {
            ProductDetails(product: product)
        } label: {
            // Display product information
        }
    }
}
```

NavigationButton is a button with navigation capabilities, uses NavigationContext.

### Display product details

```swift
import SwiftUI
import SupportKit
import SupportKitUI

struct ProductDetails: View {
    let product: Product
    
    @CollectionRequest
    private var productReviews: [Product.Review]
    
    @CollectionRequest
    private var relatedProducts: [Product]

    enum TabItem {
        case reviews
        case related
    }
    
    @State private var selectedTabItem: TabItem = .reviews

    var body {
        ScrollView {
            // Display product information
            
            Picker(selection: $selectedTabItem) {
                Text("Reviews")
                    .tag(.reviews)
                Text("Related")
                    .tag(.related)
            }
            .pickerStyle(.segmented)
            
            switch selectedTabItem {
            case .reviews:
                reviewList()
            case .related:
                relatedList()
            }
        }
        .safeAreaInset(edge: .bottom) {
            NavigationButton("Add Review", destination: .sheet) {
                ProductReviewView(product: product)
                    .navigationContainer()
            }
        }
        .navigationTitle("Product Details")
    }
}

// MARK: - Components
extension ProductDetails {
    func reviewList() -> some View {
        AsyncView(_productReviews) { phase in
            // Handle state and display reviews
        }
        .fetch(_productReviews) {
            try await product.reviews
        }
    }
    
    func relatedList() -> some View {
        AsyncView(_relatedProducts) { phase in
            // Handle state and display related products
        }
        .fetch(_relatedProducts) {
            try await product.relatedProducts
        }
    }
}
```

### Review product

AsyncButton is a button with async throw capabilities, this button change it state during task execution and present an error alert on task failure.

```swift
import SwiftUI
import SupportKitUI

struct ProductReviewView: View {
    let product: Product

    @State private var rating: Int = 0
    @State private var comment: String = ""

    var body {
        ScrollView {
            // Display rating and comment form elements
        }
        .safeAreaInset(edge: .bottom) {
            AsyncButton("Submit") {
                try await product.sendReview(rating: rating, comment: comment)
            }
            .disabled(rating == 0)
        }
        .navigationTitle("Product Review")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                DismissContainerButton("Cancel") // Dismiss the stack
            }
        }
    }
}
```

### Updates when a product changes

Use NotificationCenter, post and observe APIClient global notifications and data changes notifications

```swift
extension Notification.Name {
    public static let APIClientUnconnected = Notification.Name("APIClientUnconnected")
    public static let APIClientUnauthorized = Notification.Name("APIClientUnauthorized")
    public static let APIClientForbidden = Notification.Name("APIClientForbidden")
    public static let APIClientDataInserted = Notification.Name("APIClientDataInserted")
    public static let APIClientDataUpdated = Notification.Name("APIClientDataUpdated")
    public static let APIClientDataDeleted = Notification.Name("APIClientDataDeleted")
    public static let APIClientDataInvalidated = Notification.Name("APIClientDataInvalidated")
}
```

## Useful Links

[Swift](https://developer.apple.com/swift/)

[SwiftUI](https://developer.apple.com/xcode/swiftui/)

[SwiftData](https://developer.apple.com/xcode/swiftdata/)

[An Introduction to MV Pattern](https://swiftandtips.com/is-mvvm-necessary-for-developing-apps-with-swiftui)
