//
//  ContentView.swift
//  Calculator
//
//  Created by DavidLiu on 3/10/2023.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}


struct ContentView: View {
    
    @State private var orientation = UIDeviceOrientation.unknown
    
    @StateObject private var calculatorVM = CalculatorViewModel()
    
    func buttonWidth(item: CalcuButton, mode: String) -> CGFloat {
        if orientation.isLandscape {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = (UIScreen.main.bounds.width - (50 * 12)) / 6
                if item == .zero && mode == "DEC" {
                    return width * 2 + 12
                }
                if (item == .clear || item == .equal) && mode == "HEX" {
                    return width * 2 + 12
                }
                return width
            }
            
            let width =  (UIScreen.main.bounds.width - (50 * 12)) / 6
            if item == .zero && mode == "DEC" {
                return width * 2 + 12
            }
            if (item == .clear || item == .equal) && mode == "HEX" {
                return width * 2 + 12
            }
            return width
        } else if orientation.isPortrait {
            if UIDevice.current.userInterfaceIdiom == .pad {
                let width = (UIScreen.main.bounds.width - (30 * 12)) / 4
                if item == .zero && mode == "DEC" {
                    return width * 2 + 12
                }
                return width
            }
            
            let width =  (UIScreen.main.bounds.width - (5 * 12)) / 4
            if item == .zero && mode == "DEC" {
                return width * 2 + 12
            }
            return width
        }
        return 0
    }
    
    func buttonHeight() -> CGFloat {
        if orientation.isLandscape {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return (UIScreen.main.bounds.width - (50 * 12)) / 6
            }
            return (UIScreen.main.bounds.width - (50 * 12)) / 6
        } else if orientation.isPortrait {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return (UIScreen.main.bounds.width - (30 * 12)) / 4
            }
            return (UIScreen.main.bounds.width - (5 * 12)) / 4
        }
        return 0
    }
    
    var body: some View {
        Group {
            if orientation.isPortrait {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Mode: \(calculatorVM.selectedMode)")
                            .bold()
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding(.top, 3)
                        
                        Picker("Mode", selection: $calculatorVM.selectedMode) {
                            ForEach (calculatorVM.mode , id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(Color.blue)
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Text(calculatorVM.valueList)
                                .bold()
                                .font(.system(size: 35))
                                .foregroundColor(.white).frame(height: 30)
                        }
                        HStack {
                            Spacer()
                            Text(calculatorVM.value)
                                .bold()
                                .font(.system(size: 100))
                                .foregroundColor(.white).frame(height: 100)
                        }
                        if calculatorVM.selectedMode == "DEC" {
                            ForEach (calculatorVM.portraitDECButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 32))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            .padding(.bottom, 2)
                            Spacer()
                        } else if calculatorVM.selectedMode == "BIN" {
                            ForEach (calculatorVM.portraitBINButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 32))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            Spacer().frame(height: 12)
                            ForEach(0..<4) { _ in
                                HStack(spacing: 12) {
                                    Spacer().frame(height: self.buttonHeight())
                                }
                            }
                            Spacer().frame(height: 12)
                                .padding(.bottom, 2)
                            Spacer()
                        } else if calculatorVM.selectedMode == "HEX" {
                            ForEach (calculatorVM.portraitHEXButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 32))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            .padding(.bottom, 2)
                            Spacer()
                        }
                    }
                }
            } else if orientation.isLandscape {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    VStack {
                        Text("Mode: \(calculatorVM.selectedMode)")
                            .bold()
                            .font(.system(size: 25))
                            .foregroundColor(.white)
                            .padding(.top, 3)
                        
                        Picker("Mode", selection: $calculatorVM.selectedMode) {
                            ForEach (calculatorVM.mode , id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .background(Color.blue)
                        
                        Spacer()
                        HStack {
                            Text(calculatorVM.valueList)
                                .bold()
                                .font(.system(size: 30))
                                .foregroundColor(.white).frame(height: 50)
                            Spacer()
                            Text(calculatorVM.value)
                                .bold()
                                .font(.system(size: 50))
                                .foregroundColor(.white).frame(height: 50)
                        }
                        if calculatorVM.selectedMode == "DEC" {
                            ForEach (calculatorVM.landscapeDECButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 25))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            .padding(.bottom, 2)
                            Spacer()
                        } else if calculatorVM.selectedMode == "BIN" {
                            ForEach (calculatorVM.landscapeBINButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 25))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            if UIDevice.current.userInterfaceIdiom == .pad {
                                ForEach(0..<3) { _ in
                                    HStack(spacing: 12) {
                                        Spacer().frame(height: self.buttonHeight())
                                    }
                                }
                                Spacer().frame(height: 10)
                                    .padding(.bottom, 2)
                            } else {
                                Spacer().frame(height: 15)
                                ForEach(0..<2) { _ in
                                    HStack(spacing: 12) {
                                        Spacer().frame(height: self.buttonHeight())
                                    }
                                }
                                Spacer().frame(height: 12)
                                    .padding(.bottom, 2)
                            }
                        } else if calculatorVM.selectedMode == "HEX" {
                            ForEach (calculatorVM.landscapeHEXButtons, id: \.self) { row in
                                HStack (spacing: 12) {
                                    ForEach (row, id: \.self) {item in
                                        Button(action: {
                                            calculatorVM.didTap(button: item)
                                            print(item.rawValue)
                                        }, label: {
                                            Text(item.rawValue)
                                                .font(.system(size: 25))
                                                .frame(width: self.buttonWidth(item: item, mode: calculatorVM.selectedMode), height: self.buttonHeight())
                                                .background(item.buttonColor)
                                                .foregroundColor(.white)
                                                .cornerRadius(self.buttonHeight() / 2)
                                        })
                                    }
                                }
                                .padding(.bottom, 2)
                            }
                            .padding(.bottom, 2)
                            Spacer()
                        }
                    }
                }
            }
        }
        .onRotate { newOrientation in
            orientation = newOrientation
        }
    }
}



#Preview {
    ContentView()
}
