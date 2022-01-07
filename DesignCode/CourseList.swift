//
//  CourseList.swift
//  DesignCode
//
//  Created by Nick Rice on 06/01/2022.
//

import SwiftUI

struct CourseList: View {
    @State var courses = courseData
    @State var active = false
    @State var activeIndex = -1
    @State var activeView = CGSize.zero
    
    var body: some View {
        ZStack {
            Color.black.opacity(Double(self.activeView.height/500))
                .animation(.linear)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 30) {
                    Text("Courses")
                        .font(.largeTitle).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                        .padding(.top, 30)
                        .blur(radius: active ? 20 : 0)
                    
                    ForEach(courses.indices, id: \.self) { index in // this provides the index to target the value we want
                        GeometryReader { geometry in
                            CourseView(
                                show: self.$courses[index].show,
                                course: self.courses[index],
                                active: self.$active,
                                index: index,
                                activeIndex: self.$activeIndex,
                                activeView: self.$activeView) // we need to add self as we're inside a GeometryReader
                                .offset(y: self.courses[index].show ? -geometry.frame(in: .global).minY : 0) // is the second card in fullscreen? If yes, we're going to use -minY to offset it to fill the gap. Else, don't change anythign, set the offset Y to 0.
                                .opacity(self.activeIndex != index && self.active ? 0 : 1) // if the card is not the one being activated
                                .scaleEffect(self.activeIndex != index && self.active ? 0.5 : 1)
                                .offset(x: self.activeIndex != index && self.active ? screen.width : 0)
                        }
                        .frame(height: 280)
                        .frame(maxWidth: self.courses[index].show ? .infinity : screen.width - 60)
                        .zIndex(self.courses[index].show ? 1 : 0) // by default all the cards have a z index of 0 but if it is active it will be on top
                    }
                }
                .frame(width: screen.width)
                .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            }
            .statusBar(hidden: active ? true : false)
        }
//        .animation(.linear)
    }
}

struct CourseList_Previews: PreviewProvider {
    static var previews: some View {
        CourseList()
    }
}

struct CourseView: View {
    @Binding var show: Bool
    var course: Course
    @Binding var active: Bool
    var index: Int
    @Binding var activeIndex: Int
    @Binding var activeView: CGSize
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 30.0) {
                Text("Take your SwiftUI app to the App Store with advanced techniques like API data, packages and CMS.")
                
                Text("About this course")
                    .font(.title).bold()
                
                Text("This course is unlike any other. We care about design and want to make sure that you get better at it in the process. It was written for designers and developers who are passionate about collaborating and building real apps for iOS and macOS. While it's not one codebase for all apps, you learn once and can apply the techniques and controls to all platforms with incredible quality, consistency and performance. It's beginner-friendly, but it's also packed with design tricks and efficient workflows for building great user interfaces and interactions.")
                
                Text("Minimal coding experience required, such as in HTML and CSS. Please note that Xcode 11 and Catalina are essential. Once you get everything installed, it'll get a lot friendlier! I added a bunch of troubleshoots at the end of this page to help you navigate the issues you might encounter.")
            }
            .padding(30)
            .frame(maxWidth: CGFloat(show ? .infinity : screen.width - 60), maxHeight: CGFloat(show ? .infinity : 280.0), alignment: .top)
            .offset(y: show ? 460 : 0)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
            .opacity(show ? 1 : 0)
            
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(course.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(course.subtitle)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    Spacer()
                    ZStack {
                        Image(uiImage: course.logo)
                            .opacity(show ? 0 : 1)
                        
                        VStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 36, height: 36)
                        .background(Color.black)
                        .clipShape(Circle())
                        .opacity(show ? 1 : 0)
                    }
                }
                Spacer()
                Image(uiImage: course.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140, alignment: .top)
            }
            .padding(show ? 30 : 20) // the different padding for when it is a card vs fullscreen
            .padding(.top, show ? 30 : 0) // the different padding for when it is a card vs fullscreen
    //        .frame(width: show ? screen.width : screen.width - 60, height: show ? screen.height : 280)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? 460 : 280) // take the full screen width, otherwise indent by 60. Take the max height, otherwise set it to 280. This ensures to take the full width and height when show is set to true. But infity respects the safe area.
            .background(Color(course.color))
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
            .shadow(color: Color(course.color).opacity(0.3), radius: 20, x: 0, y: 20)
            .gesture(
                show ?
                DragGesture().onChanged { value in
                    guard value.translation.height < 300 else { return } // if it isn't meeting the condition then stop running the code from here
                    guard value.translation.height > 0 else { return }
                    
                    self.activeView = value.translation
                }
                .onEnded { value in
                    if self.activeView.height > 50 {
                        self.show = false
                        self.active = false
                        self.activeIndex = -1
                    }
                    self.activeView = .zero
                } // whenever we drag we'll get the translation to our active view and when we release it is going to reset that value.
                : nil
            )
            .onTapGesture {
                self.show.toggle()
                self.active.toggle()
                if self.show {
                    self.activeIndex = self.index
                } else {
                    self.activeIndex = -1
                }
            }
            
//            if show {
//                CourseDetail(course: course, show: $show, active: $active, activeIndex: $activeIndex)
//                    .background(Color.white)
//                    .animation(nil)
//            }
        }
        .frame(height: show ? screen.height : 280)
        .scaleEffect(1 - self.activeView.height / 1000)
        .rotation3DEffect(Angle(degrees: Double(self.activeView.height / 10)), axis: (x: 0, y: 10.0, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
        .hueRotation(Angle(degrees: Double(self.activeView.height)))
        .gesture(
            show ?
            DragGesture().onChanged { value in
                guard value.translation.height < 300 else { return } // if it isn't meeting the condition then stop running the code from here
                guard value.translation.height > 0 else { return }
                
                self.activeView = value.translation
            }
            .onEnded { value in
                if self.activeView.height > 50 {
                    self.show = false
                    self.active = false
                    self.activeIndex = -1
                }
                self.activeView = .zero
            } // whenever we drag we'll get the translation to our active view and when we release it is going to reset that value.
            : nil
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct Course: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var image: UIImage
    var logo: UIImage
    var color: UIColor
    var show: Bool
}

var courseData = [
    Course(title: "Prototype Designs in SwiftUI", subtitle: "18 Sections", image: #imageLiteral(resourceName: "Background1"), logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), show: false),
    Course(title: "SwiftUI Advanced", subtitle: "20 Sections", image: #imageLiteral(resourceName: "Card3"), logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), show: false),
    Course(title: "UI Design for Developers", subtitle: "20 Sections", image: #imageLiteral(resourceName: "Card4"), logo: #imageLiteral(resourceName: "Logo3"), color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), show: false)
]
