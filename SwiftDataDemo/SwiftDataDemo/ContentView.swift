//
//  ContentView.swift
//  SwiftDataDemo
//
//  Created by Steven Lipton on 6/14/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var prefs: [UserPref]
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
                let newId = (prefs.map{$0.id}.max() ?? -1) + 1
                let newItem = UserPref(id: newId, hasPencil: pref.hasPencil)
                modelContext.insert(newItem)
                pref = newItem
            }
            .padding()
            .background(.thickMaterial, in:RoundedRectangle(cornerRadius: 10))
            ForEach(prefs){ item in
                Text("ID:\(item.id) Pencil:" + (item.hasPencil ? "true":"false"))
            }
        }
        .onAppear {
            pref = prefs.last ?? pref
        }
        
    }
       
}

#Preview {
    ContentView()
}
