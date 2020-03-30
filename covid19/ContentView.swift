//
//  ContentView.swift
//  covid19
//
//  Created by miguel tomairo on 3/28/20.
//  Copyright © 2020 rapser. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Home: View {
    
    @ObservedObject var res = getData()
    
    var body: some View {
        
        VStack{
            
            if self.res.countries.count != 0 && self.res.data != nil {
                
                VStack{
                    HStack(alignment: .top){
                        
                        VStack(alignment: .leading, spacing: 15) {
                            
                            Text("Actualizado: " + getDate(time: self.res.data.updated))
                                .fontWeight(.light)
                                .font(.system(size: 12))
                                .foregroundColor(.white)
                            
                            Text("COVID-19 #Casos")
                                .fontWeight(.semibold)
                                .font(.subheadline)
                                .foregroundColor(.white)
                            
                            Text(getValue(data: self.res.data.cases))
                                .fontWeight(.bold)
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            self.res.data = nil
                            self.res.countries.removeAll()
                            self.res.updateData()
                        }) {
                            Image(systemName: "arrow.clockwise")
                            .font(.title)
                            .foregroundColor(.white)
                        }
                    }
                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top)! + 18)
                    .padding()
                    .padding(.bottom, 80)
                    .background(Color.red)
                    
                    HStack(spacing: 15){
                        
                        VStack(alignment: .center, spacing: 15) {
                            Text("Muertes")
                                .foregroundColor(Color.black.opacity(0.5))
                            
                            Text(getValue(data: self.res.data.deaths))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                        }
                        .padding(30)
                        .background(Color.white)
                        .cornerRadius(12)
                        
                        VStack(alignment: .center, spacing: 15) {
                             Text("Recuperados")
                                 .foregroundColor(Color.black.opacity(0.5))
                             
                            Text(getValue(data: self.res.data.recovered))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                         }
                         .padding(30)
                         .background(Color.white)
                         .cornerRadius(12)
                    }
                    .offset(y: -60)
                    .padding(.bottom, -60)
                    .zIndex(25)
                    
                    VStack(alignment: .center, spacing: 15) {
                             Text("Casos Activos")
                                 .foregroundColor(Color.black.opacity(0.5))
                             
                        Text(getValue(data: self.res.data.active))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        
                     }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 30)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.top, 15)
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        
                        HStack(spacing: 15){
                            ForEach(self.res.countries, id: \.self){i in
                                cellView(data: i)
                            }
                        }
                        .padding()
                    }
                }
                
            }else {
                GeometryReader {_ in
                    
                    VStack {
                        Indicator()
                    }
                }
            }
                        
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.black.opacity(0.1).edgesIgnoringSafeArea(.all))
        
    }

}

func getDate(time: Double) -> String {
    
    let date = Double(time / 1000)
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.locale = Locale(identifier: "es_PE")
//    formatter.dateFormat = "dd 'de' MMMM 'del' YYYY hh:mm a"
    
    return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(exactly: date)!))
}

func getValue(data: Double) -> String {
    
    let format = NumberFormatter()
    format.numberStyle = .decimal
    
    return format.string(from: NSNumber(value: data))!
}

struct cellView: View{
    
    var data: Details
    
    var body: some View {
    
        VStack(alignment: .leading, spacing: 15) {
            
            Text(data.country)
            .fontWeight(.bold)
            .foregroundColor(Color.black.opacity(0.5))
            
            HStack(spacing: 22){
                
                VStack(alignment: .leading, spacing: 12){
                    Text("Casos Activos")
                    .font(.title)
                    .foregroundColor(Color.black.opacity(0.5))
                    
                    Text(getValue(data: data.cases))
                    .font(.title)
                    .foregroundColor(Color.black.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 10){
                        
                        Text("Muertes")
                        .foregroundColor(Color.black.opacity(0.5))
                        
                        Text(getValue(data: data.deaths))
                        .foregroundColor(.red)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10){
                        
                        Text("Recuperados")
                        .foregroundColor(Color.black.opacity(0.5))
                        
                        Text(getValue(data: data.recovered))
                        .foregroundColor(.green)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10){
                        
                        Text("Criticos")
                        .foregroundColor(Color.black.opacity(0.5))
                        
                        Text(getValue(data: data.critical))
                        .foregroundColor(.yellow)
                    }
                    
                }
            }
        }
        .padding()
        .frame(width: UIScreen.main.bounds.width - 30)
        .background(Color.white)
        .cornerRadius(20)
        
    }
}

struct Case: Decodable {
    var cases: Double
    var deaths: Double
    var updated: Double
    var recovered: Double
    var active: Double
}

struct Details: Decodable, Hashable {
    var country: String
    var cases: Double
    var deaths: Double
    var recovered: Double
    var critical: Double
}

class getData: ObservableObject {
    
    @Published var data : Case!
    @Published var countries = [Details]()
    
    init() {
        updateData()
    }
    
    func updateData() {
        
        let url = "https://corona.lmao.ninja/all"
        let url1 = "https://corona.lmao.ninja/countries/"
        
        let session = URLSession(configuration: .default)
        let session1 = URLSession(configuration: .default)

        session.dataTask(with: URL(string: url)!) { (data, _, err) in
            
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            let json = try! JSONDecoder().decode(Case.self, from: data!)
            
            DispatchQueue.main.async {
                self.data = json
            }
        }.resume()
        
        for i in country {
            session1.dataTask(with: URL(string: url1 + i)!) { (data, _, err) in
                
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                
                let json = try! JSONDecoder().decode(Details.self, from: data!)
                
                DispatchQueue.main.async {
                    self.countries.append(json)
                }
            }.resume()
        }
    
    }
    
}

var country = ["peru","ecuador","colombia","brasil","uruguay","paraguay","bolivia","chile","argentina","venezuela"]

struct Indicator: UIViewRepresentable {
    
    func makeUIView(context: UIViewRepresentableContext<Indicator>) -> UIActivityIndicatorView {
        
        let view = UIActivityIndicatorView(style: .large)
        view.startAnimating()
        
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Indicator>) {
        
    }
}
