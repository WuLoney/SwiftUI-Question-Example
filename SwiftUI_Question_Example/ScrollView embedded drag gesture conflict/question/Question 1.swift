//
//  Question 1.swift
//  SwiftUI_Question_Example
//
//  Created by wulilian on 2025/6/11.
//

import SwiftUI
import Combine

struct Question1View: View {
    
    @State private var userSelected: Bool?
    
    var body: some View {
        
        ScrollView(.vertical, showsIndicators: false) {
            
            Question1SubView(
                subColumns: ["", "", "", "", ""],
                userSelected: $userSelected) { model in
                    VStack {
                        
                    }
                }
                .frame(height: 262)
        }
    }
}


struct Question1SubView<Content, T>: View where Content: View {
    
    //按钮与卡片联动字段
    @State private var offsetX: CGFloat = 0
    @State private var scrollIndex: Int = 0
    @State private var index: Int = 0
    @GestureState var isGestureFinished = true
    
    @State private var cardWidth: CGFloat = 0
    @State private var mTabIndex: Int = 1
    @State private var dragOffset: CGFloat = 0
    @State private var currentIndex: Int = 0
    @State private var contentWidth: CGFloat = 0
    
    @State var dragGestureValue: DragGesture.Value?
    @State private var isDragGestureFinished = false
    
    @State private var startScrollOffsetY: CGFloat = 0
    
    // Configuration
    private let elasticityFactor: CGFloat = 0.99
    private let accelerationFactor: CGFloat = 0.95 // Higher = more sensitive to velocity

    /// 是否用户主动选择
    @Binding private var userSelected: Bool?
    public var onScrollChange: (Int) -> Void
    private let subColumns: [T]
    private let spacing: CGFloat
    private let tabSpacing: CGFloat
    private let trailingSpace: CGFloat
    private let contentHorizontalSpace: CGFloat
    private let dividerEnable: Bool
    private var content: (T) -> Content
    
    init(
        subColumns: [T],
        userSelected: Binding<Bool?>,
        tabSpacing: CGFloat = 8,
        spacing: CGFloat = 8,
        trailingSpace: CGFloat = 0,
        contentHorizontalSpace: CGFloat = 12,
        dividerEnable: Bool = false,
        onScrollChange: @escaping (Int) -> Void = { _ in },
        @ViewBuilder content: @escaping (T) -> Content) {
            self.subColumns = subColumns
            self._userSelected = userSelected
            self.tabSpacing = tabSpacing
            self.spacing = spacing
            self.trailingSpace = trailingSpace
            self.contentHorizontalSpace = contentHorizontalSpace
            self.dividerEnable = dividerEnable
            self.content = content
            self.onScrollChange = onScrollChange
        }
    
    private func getOffset(_ width: CGFloat) -> CGFloat {
        
        if currentIndex < self.subColumns.count - 1 && currentIndex >= 0 {
            return  -CGFloat(currentIndex) * width + dragOffset - CGFloat(currentIndex) * spacing
        } else {
            return  -CGFloat(currentIndex) * width + dragOffset + trailingSpace - CGFloat(currentIndex) * spacing
        }
    }
    
    private func dragChanged(_ value: DragGesture.Value) {
        dragGestureValue = value
        
        // Apply elasticity at boundaries
        if (currentIndex == 0 && value.translation.width > 0) ||
            (currentIndex >= Int((contentWidth / cardWidth) - 1) && value.translation.width < 0) {
            dragOffset = value.translation.width * elasticityFactor // Elasticity factor
        } else {
            dragOffset = value.translation.width
        }
        
        if self.userSelected != nil && !self.userSelected! {
            self.userSelected = true
        }
    }
    
    private func dragEnded(_ value: DragGesture.Value) {
        
        guard isGestureFinished else { return }
        
        dragGestureValue = nil
        
        // Calculate velocity
        let velocity = value.predictedEndLocation.x - value.location.x
        
        // Actual drag distance
        let dragDistance = value.translation.width
        
        // Acceleration-based additional distance
        let accelerationDistance = velocity * accelerationFactor
        
        // Total effective distance (drag + acceleration)
        let effectiveDistance = dragDistance + accelerationDistance
        
        // Threshold is half card width (center of adjacent card)
        let thresholdDistance = cardWidth / 2
        
        var targetIndex = currentIndex
        
        // Determine whether to move to next card based on direction and effective distance
        if dragDistance > 0 {
            // Swiping right (trying to see previous card)
            if effectiveDistance > thresholdDistance && currentIndex > 0 {
                // If effective distance passes threshold, move to previous card
                targetIndex = currentIndex - 1
            }
        } else {
            // Swiping left (trying to see next card)
            if -effectiveDistance > thresholdDistance && currentIndex < Int(contentWidth / cardWidth) - 1 {
                // If effective distance passes threshold, move to next card
                targetIndex = currentIndex + 1
            }
        }
        
        if self.userSelected != nil && !self.userSelected! {
            self.userSelected = true
        }
        
        // Skip intermediate acceleration animation and directly go to result
        withAnimation(.spring(response: 0.3, dampingFraction: 0.99)) {
            currentIndex = targetIndex
            
            onScrollChange(currentIndex)
            dragOffset = 0
            
//            if self.columns != nil {
//                // 1. 根据index取出子模块数据
//                let subModule = self.subColumns[currentIndex]
//                // 2. 根据子模块找出主模块的索引
//                if let mainIndex = self.columns!.firstIndex(where: { $0.id == subModule.mTabId}) {
//                    // 3. 赋值主模块，改变主模块位置
//                    self.scrollIndex = mainIndex
//                }
//            }
        }
    }
    
//    private func selecteColumnOffset() {
//        
//        guard selectColumn != nil && self.userSelected != nil && !self.userSelected! else { return }
//        
//        // 主图选中的索引
//        if self.columns != nil,
//           let tabIndex = self.columns!.firstIndex(where: { $0.id == self.selectColumn!.id })  {
//            
//            DispatchQueue.main.async {
//                self.scrollIndex = tabIndex
//            }
//        }
//        
//        if let subIndex = self.subColumns.firstIndex(where: { $0.mTabId == self.selectColumn!.id }) {
//            DispatchQueue.main.async {
//                self.currentIndex = subIndex
//            }
//        }
//    }
    
    var body: some View {
        
        let dragGesture = DragGesture()
            .updating($isGestureFinished) { _, state, _ in
                state = false
            }
            .onChanged(dragChanged)
        
        let tapGesture = TapGesture(count: 2)
            .onEnded { value in
                
            }
        
        GeometryReader { proxy -> AnyView in
            DispatchQueue.main.async {
                self.cardWidth = proxy.size.width - trailingSpace
            }
            
            return AnyView(
                // 卡片
                HStack(spacing: spacing) {
                    ForEach(0..<self.subColumns.count, id: \.self) { index in
                        self.content(self.subColumns[index])
                            .frame(width: proxy.size.width - trailingSpace)
                    }
                }
                    .background(
                        GeometryReader { geometryProxy -> Color in
                            DispatchQueue.main.async {
                                self.contentWidth = geometryProxy.frame(in: .global).size.width
                            }
                            return Color.white
                        }
                    )
                    .offset(x: getOffset(cardWidth))
                    .simultaneousGesture(dragGesture)
                    .highPriorityGesture(
                        tapGesture
                            .exclusively(before: dragGesture)
                    )
                    .onChange(of: isGestureFinished) { value in
                        if value && dragGestureValue != nil {
                            dragEnded(dragGestureValue!)
                        }
                    }
                    .onReceive(Just(isDragGestureFinished), perform: { newValue in
                        if newValue && dragGestureValue != nil {
                            dragEnded(dragGestureValue!)
                            self.isDragGestureFinished = false
                        }
                    })
            )
        }
        .padding(.horizontal, contentHorizontalSpace)
        Spacer(minLength: 0)
        
    }
}
