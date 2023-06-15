# Swift Data First Impressions

*A copy of the article you can find at [MakeAppPie.com](https://makeapppie.com/2023/06/15/first-impressions-of-swift-data/) which uses this repository*


One of my biggest excitements from WWDC23 was the introduction of Swift Data, a persistent memory system for Swift and SwiftUI. It promises to deliver fast and easy persistence to projects compared to core data. 

As someone who has tried to learn CoreData three times and failed, I'm especially interested if this will work as advertised. So I downloaded Xcode 15 beta 1 and tried it out on a simple project: a preferences system for a toggle. 

What I found was surprising to me. Yes, it is easy, but there are a lot of caveats Apple doesn't mention. If you got used to SwiftUI, you'll have to make some changes in thinking. Again this was on beta 1, so the bugs were abundant as ants at a picnic. Expect much of this to change as development continues. 

There is a template for SwiftData in Xcode, but like most of those templates, it is more of a bother than a blessing. I started from scratch without the template. However, I suggest looking at the template for another SwiftData code demo. 

After creating the project **SwiftDataDemo**, I set out to make the model for my data Like this:

```
import Foundation
import SwiftData
@Model
class UserPref:Identifiable{
    var id:Int
    var hasPencil:Bool
    
    init(id:Int,hasPencil:Bool){
        self.id = id
        self.hasPencil = hasPencil
    }
}
```

This is an introductory class with two properties. One of the properties, `id` was from adopting `Identifiable`. Iteration in SwiftUI works, as the results later in our code are hashable, but with this model, we will end up with non-unique data. There is the `@Attribute` to add uniqueness constraints, but for this first app, I kept it simple. 
The SwiftData `@Model` macro does the magic here, making this a record structure we can use in Swift Data. 

To register this model container, you use the `.modelContainer` modifier on the window group of your App file, in my case, `SwiftDataDemoApp`. 

```
import SwiftUI
import SwiftData

@main
struct SwiftDataDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: UserPref.self)
    }
}
```

Next, in ContentView, I made a straightforward view of an image, toggle, and button. It contains a `@State` Variable I use to drive the image based on the state of the toggle. 

```
@State private var pref: UserPref = UserPref(id: -1, hasPencil: true)
var body: some View {
    VStack {
        Text("SwiftData Prefs demo")
            .font(.title)
            .padding()
        Image(systemName: pref.hasPencil ? "pencil.circle" : "circle")
            .resizable()
            .scaledToFit()
        Toggle("Has Pencil", isOn: $pref.hasPencil)
        Button("Save") {
				
			
        }
        .padding()
        .background(.thickMaterial, in:RoundedRectangle(cornerRadius: 10))
        
        }

```

The code, as written, does not use persistence. Besides including Swift Data in `ContentView`, You need two more properties in the `ContentView` to use Swift Data. The first is an environment variable, `modelcontext`, used to add or delete items in the model.  

```
@Environment(\.modelContext) private var modelContext
```

The second creates a non-mutable array of your model type using 
the `@Query` macro. You'll use this to read and change values. 

```
@Query private var prefs: [UserPref]
```

I'll use the last element for my preferences app as the current one. If the array is empty, I'll use the default I set in `@State`. This gets placed in a `.onAppear` modifier to the root `VStack` of `ContentView`. 

```
.onAppear {
	pref = prefs.last ?? pref
}
```

In the Save button's action, I'll make every entry unique. I'll create a variable `newId`, which is always one more than the highest value ID available for my next record.  

```
let newId = (prefs.map{$0.id}.max() ?? -1) + 1
let newItem = UserPref(id: newId, hasPencil: pref.hasPencil)
```
Then insert this into the persistent model using the `modelContext`: 

```
modelContext.insert(newItem)
```

Finally, I get to an important caveat about Swift Data. Remember, `UserData` is a class and thus a reference type. Although a value type, the state variable `pref` also points to the element in the `prefs` array. If you change `pref`, you change that element in `prefs`. SwiftData will also record that change. If you shut down the app, your penultimate record will have the persistent change, not the last one. To solve this, you want to point to the most current record. Set `pref` equal to this new record. 

```
pref = newItem
```


For a real app, I would not include this, but to show what is happening with SwiftData, I added a `ForEach` to watch the elements in my array prefs change. 

```
ForEach(prefs){ item in
   Text("ID:\(item.id) Pencil:" + (item.hasPencil ? "true":"false"))
}
```

Xcode 15 beta 1 reminded me quickly that this is beta 1. Swift Data and previews still need to play better together. I got fatal crashes using this code. However, it will run on devices and simulators. Run it from the simulator. I'll rotate the device for a better layout in this article. You'll get the following:  



Click **Save**, and you get a persistent entry. 


Turn the pencil off. The persistent entry changes to *false*

Stop the app. Run again, and the app remembers the pencil was off.

Tap **Save** again, then turn the pencil on again. The new entry has *true*. 

Close the app, and open it again. We have the remembered pencil. 

This is a sample app to test how to compose code for SwiftData. A lot will change between now and production Xcode, and I only explored some features. However, something as simple as remembering a bool value presents enough issues to watch for as you begin to code in SwiftData. 

SwiftData has a lot of promise to make persistent data much easier for developers to use within Swift and SwiftUI. My first impressions are positive, though there are several places where how we think about common data structures will need some changing to use Swift data properly. I look forward to seeing how much change comes to other betas, even in a few weeks, and if many of the bugs and crashes I ran into will disappear.

