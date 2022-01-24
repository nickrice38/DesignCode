//
//  HomeView.swift
//  DesignCode
//
//  Created by Nick Rice on 30/12/2021.
//

import SwiftUI

struct HomeView: View {
    @Binding var showProfile: Bool
    @Binding var showContent: Bool
    @State private var showUpdate = false
    @Binding var viewState: CGSize
    @ObservedObject var store = CourseStore()
    @State var active = false
    @State var activeIndex = -1
    @State var activeView = CGSize.zero
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { bounds in
            ScrollView {
                VStack {
                    HStack {
                        Text("Watching")
                            .font(.system(size: 28, weight: .bold)) // this will replace the custom modifier below
                            .modifier(CustomFontModifier(size: 28))
                        
                        Spacer()
                        
                        AvatarView(showProfile: self.$showProfile)
                        
                        Button(action:{ self.showUpdate.toggle() }) {
                            Image(systemName: "bell")
                                .foregroundColor(.primary)
                            //                        .renderingMode(.original)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 36, height: 36)
                                .background(Color("background3"))
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
                        }
                        .sheet(isPresented: self.$showUpdate) {
                            UpdateList()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.leading, 14)
                    .padding(.top, 30)
                    .blur(radius: self.active ? 20 : 0)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        WatchRingsView()
                            .padding(.horizontal, 30)
                            .padding(.bottom, 30)
                            .onTapGesture {
                                self.showContent = true
                            }
                    }
                    .blur(radius: self.active ? 20 : 0)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(sectionData) { item in
                                    GeometryReader { geometry in
                                        SectionView(section: item)
                                            .rotation3DEffect(Angle(degrees:
                                                Double(geometry.frame(in: .global).minX - 30) / -getAngleMultiplier(bounds: bounds)
                                            ), axis: (x: 0, y: 10, z: 0))
                                    }
                                    .frame(width: 275, height: 275)
                                }
                            }
                            .padding(30)
                            .padding(.bottom, 30)
                        }
                        .offset(y: -30)
                        .blur(radius: self.active ? 20 : 0)
                    
                    HStack {
                        Text("Courses")
                            .font(.title).bold()
                        Spacer()
                    }
                    .padding(.leading, 30)
                    .offset(y: -60)
                    .blur(radius: self.active ? 20 : 0)
                    
                    VStack(spacing: 30) {
                        ForEach(self.store.courses.indices, id: \.self) { index in // this provides the index to target the value we want
                            GeometryReader { geometry in
                                CourseView(
                                    show: self.$store.courses[index].show,
                                    course: self.store.courses[index],
                                    active: self.$active,
                                    index: index,
                                    activeIndex: self.$activeIndex,
                                    activeView: self.$activeView, bounds: bounds) // we need to add self as we're inside a GeometryReader
                                    .offset(y: self.store.courses[index].show ? -geometry.frame(in: .global).minY : 0) // is the second card in fullscreen? If yes, we're going to use -minY to offset it to fill the gap. Else, don't change anythign, set the offset Y to 0.
                                    .opacity(self.activeIndex != index && self.active ? 0 : 1) // if the card is not the one being activated
                                    .scaleEffect(self.activeIndex != index && self.active ? 0.5 : 1)
                                    .offset(x: self.activeIndex != index && self.active ? bounds.size.width : 0)
                            }
                            .frame(height: self.horizontalSizeClass == .regular ? 80 : 280)
                            .frame(maxWidth: self.store.courses[index].show ? 712 : getCardWidth(bounds: bounds))
                            .zIndex(self.store.courses[index].show ? 1 : 0) // by default all the cards have a z index of 0 but if it is active it will be on top
                        }
                    }
                    .padding(.bottom, 300)
                    .offset(y: -60)
                        
                    Spacer()
                }
                .frame(width: bounds.size.width) // GeometryReader using our bounds value supports split screen
                .offset(y: self.showProfile ? -450 : 0)
                .rotation3DEffect(Angle(degrees: self.showProfile ? Double(self.viewState.height / 10) - 10 : 0), axis: (x: 10.0, y: 0, z:0))
                .scaleEffect(self.showProfile ? 0.9 : 1)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            }
        }
        }
    }
    
func getAngleMultiplier(bounds: GeometryProxy) -> Double {
    if bounds.size.width > 500 {
        return 80
    } else {
        return 20
    }
}

    struct HomeView_Previews: PreviewProvider {
        static var previews: some View {
            HomeView(showProfile: .constant(false), showContent: .constant(false), viewState: .constant(.zero))
                .environmentObject(UserStore())
        }
    }
    
    struct SectionView: View {
        var section: Section
        var width: CGFloat = 275
        var height: CGFloat = 275
        
        var body: some View {
            VStack {
                HStack(alignment: .top) {
                    Text(section.title)
                        .font(.system(size: 24, weight: .bold))
                        .frame(width: 160, alignment: .leading)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(section.logo)
                }
                
                Text(section.text.uppercased())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                section.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 210)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .frame(width: width, height: height)
            .background(section.color)
            .cornerRadius(30)
            .shadow(color: section.color.opacity(0.3), radius: 20, x: 0, y: 20)
        }
    }
    
    struct Section: Identifiable {
        var id = UUID()
        var title: String
        var text: String
        var logo: String
        var image: Image
        var color: Color
    }
    
    let sectionData = [
        Section(title: "Prototype designs in SwiftUI", text: "18 Sections", logo: "Logo1", image: Image(uiImage: #imageLiteral(resourceName: "Card4")), color: Color(#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1))),
        Section(title: "Build a SwiftUI app", text: "20 Sections", logo: "Logo1", image: Image(uiImage: #imageLiteral(resourceName: "Background1")), color: Color(#colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))),
        Section(title: "SwiftUI Advanced", text: "20 Sections", logo: "Logo1", image: Image(uiImage: #imageLiteral(resourceName: "Card2")), color: Color(#colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)))
    ]

struct WatchRingsView: View {
    var body: some View {
        HStack(spacing: 30) {
            HStack(spacing: 12.0) {
                RingView(color1: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), color2: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), width: 44, height: 44, percent: 68, show: .constant(true))
                
                VStack(alignment: .leading, spacing: 4.0) {
                    Text("6 minutes left")
                        .bold().modifier(FontModifier(style: .subheadline))
                    
                    Text("Watched 10 minutes today")
                        .modifier(FontModifier(style: .caption))
                    
                }
                .modifier(FontModifier())
                
            }
            .padding(8)
            .background(Color("background3"))
            .cornerRadius(20)
            .modifier(ShadowModifier())
            
            HStack(spacing: 12.0) {
                RingView(color1: #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), color2: #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1), width: 32, height: 32, percent: 54, show: .constant(true))
            }
            .padding(8)
            .background(Color("background3"))
            .cornerRadius(20)
            .modifier(ShadowModifier())
            
            HStack(spacing: 12.0) {
                RingView(color1: #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1), color2: #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), width: 32, height: 32, percent: 32, show: .constant(true))
            }
            .padding(8)
            .background(Color("background3"))
            .cornerRadius(20)
            .modifier(ShadowModifier())
            
        }
    }
}
