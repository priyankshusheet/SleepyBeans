//
//  ContentView.swift
//  SleepyBeans
//
//  Created by Priyankshu Sheet on 13/07/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var cofeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient (gradient: Gradient(colors: [Color(red: 48/255, green: 30/255, blue: 13/255), Color(red: 179/255, green: 146/255, blue: 106/255)]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Text("SleepyBeans")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 224/255, green: 201/255, blue: 163/255))
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    VStack {
                        Image (systemName: "alarm")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(Color(red: 224/255, green: 201/255, blue: 163/255))
                            .padding(.bottom, 30)
                        Spacer()
                        Form {
                            Section (header: Text ("Wakey Time ???")
                                .lineLimit(1)
                                .font(.headline.bold())
                                .foregroundColor(Color(red: 111/255, green: 78/255, blue: 55/255))
                                .fontWeight(.bold)
                            ) {
                                
                                VStack {
                                    DatePicker ("", selection: $wakeUp, displayedComponents: .hourAndMinute)
                            
                                        .labelsHidden()
                                        .datePickerStyle(WheelDatePickerStyle())
                                        .background(Color(red: 224/255, green: 201/255, blue: 163/255).opacity(0.4))
                                        .cornerRadius(20)
                                        .frame(width:.infinity, height: 70)
                                        .shadow(radius: 10)
                                }
                                .frame(width: .infinity ,height: 50)
                            }
                            
                            Section(header: Text("Desired amount of sleep")
                                .font(.headline)
                                .foregroundColor(Color(red: 111/255, green: 78/255, blue: 55/255))
                                .fontWeight(.bold)
                            ) {
                                Stepper ("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                                    .padding()
                                    .background(Color(red: 224/255, green: 201/255, blue: 163/255).opacity(0.5))
                                    .frame(width: 343)
                                    .cornerRadius(10)
                                    .fontWeight(.semibold)
                            }
                            
                            Section (header: Text ("Daily Coffee intake")
                                .font(.headline)
                                .foregroundColor(Color(red: 111/255, green: 78/255, blue: 55/255))
                                .fontWeight(.bold)
                            ) {
                                
                                Stepper ("^[\(cofeeAmount) cup](inflect: true)", value: $cofeeAmount, in: 1...20)
                                    .padding()
                                    .background(Color(red: 224/255, green: 201/255, blue: 163/255).opacity(0.5))
                                    .frame(width: 343)
                                    .cornerRadius(10)
                                    .fontWeight(.semibold)
                            }
                        }
                        .background(Color(red: 179/255, green: 146/255, blue: 106/255).gradient)
                        .scrollContentBackground(.hidden)
                        .frame(height: 520)
                        .cornerRadius(20)
                        .padding(.horizontal)
                    }
                    Spacer()
                    
                    Button(action: calculateBedTime) {
                        Text("Calculate")
                            .font(.headline)
                            .foregroundColor(Color(red: 244/255, green: 236/255, blue: 220/255))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 60/255, green: 42/255, blue: 24/255))
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .padding(.horizontal)
                    }
                    Spacer()
                }
                .padding(.bottom, 20)
            }
            .alert(alertTitle, isPresented: $showingAlert) {
                Button("OK") {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedTime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(cofeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal Bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        
        catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your Bedtime"
        }
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
