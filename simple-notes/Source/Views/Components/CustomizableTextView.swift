// macOS Version taken from: https://stackoverflow.com/a/66832221

import SwiftUI

struct CustomizableTextEditor: View {
    @Binding var text: String
    private var placeholder: String
    private var fontName: String
    private var fontSize: Double
    private var numberOfLines: Int? = nil
    private var maximumWidth: CGFloat = .infinity
    
    init(text: Binding<String>, placeholder: String = "", fontName: String, fontSize: Double) {
        self._text = text
        self.placeholder = placeholder
        self.fontName = fontName
        self.fontSize = fontSize
        
    }
    
    private var internalPadding = EdgeInsets()
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .opacity(0.3)
                    .padding(internalPadding)
            }
            
#if os(macOS)
            GeometryReader { geometry in
                NSScrollableTextViewRepresentable(text: $text, fontName: fontName, fontSize: fontSize, lineLimit: numberOfLines, maxWidth: maximumWidth, size: geometry.size, textPadding: internalPadding)
            }
#else
            UIScrollableTextViewRepresentable(text: $text, fontName: fontName, fontSize: fontSize, lineLimit: numberOfLines, textPadding: internalPadding)
#endif
        }
    }
    
    func textPadding(_ edges: Edge.Set, _ ammount: CGFloat) -> Self {
        var view = self
        
        var insets = view.internalPadding
        if edges.contains(.top)      { insets.top      += ammount }
        if edges.contains(.bottom)   { insets.bottom   += ammount }
        if edges.contains(.leading)  { insets.leading  += ammount }
        if edges.contains(.trailing) { insets.trailing += ammount }
        
        view.internalPadding = insets
        
        return view
    }
    
    func textPadding(_ ammount: CGFloat) -> Self {
        textPadding(.all, ammount)
    }
    
    func lineLimit(_ n: Int) -> Self {
        var view = self
        view.numberOfLines = n
        
        return view
    }
    
    func maxWidth(_ maxW: CGFloat?) -> Self {
        var view = self
        view.maximumWidth = maxW ?? .infinity
        
        return view
    }
}

#if os(macOS)
struct NSScrollableTextViewRepresentable: NSViewRepresentable {
    typealias Representable = Self
    
    // Hook this binding up with the parent View
    @Binding var text: String
    var fontName: String
    var fontSize: Double
    var lineLimit: Int?
    
    var maxWidth: CGFloat
    var size: CGSize
    var textPadding: EdgeInsets
    
    private var nsInsets: NSSize {
        NSSize(width: textPadding.leading, height: textPadding.top)
    }
    
    // Get the UndoManager
    @Environment(\.undoManager) var undoManger
    
    // create an NSTextView
    func makeNSView(context: Context) -> NSScrollView {
        
        // create NSTextView inside NSScrollView
        let scrollView = NSTextView.scrollableTextView()
        let nsTextView = scrollView.documentView as! NSTextView
        
        // use SwiftUI Coordinator as the delegate
        nsTextView.delegate = context.coordinator
        
        // set drawsBackground to false (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        nsTextView.drawsBackground = false
        
        // allow undo/redo
        nsTextView.allowsUndo = true
        
        nsTextView.font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        // get wrapped nsTextView
        guard let nsTextView = scrollView.documentView as? NSTextView else {
            return
        }
        
        let ranges = nsTextView.selectedRanges
        
        nsTextView.font = NSFont(name: fontName, size: CGFloat(fontSize))
        
        // fill entire given size
        let size = NSSize(width: min(size.width, maxWidth), height: size.height)
//        nsTextView.maxSize = size
        nsTextView.setConstrainedFrameSize(size)
        
        // set NSTextView string from SwiftUI-Binding
        nsTextView.string = text
        
        nsTextView.selectedRanges = ranges
        
        nsTextView.textContainerInset = NSSize(width: nsInsets.width, height: nsInsets.height)
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Declare nested Coordinator class which conforms to NSTextViewDelegate
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: Representable // store reference to parent
        
        init(_ textEditor: Representable) {
            self.parent = textEditor
        }
        
        // delegate method to retrieve changed text
        func textDidChange(_ notification: Notification) {
            // check that Notification.name is of expected notification
            // cast Notification.object as NSTextView

            guard notification.name == NSText.didChangeNotification,
                let nsTextView = notification.object as? NSTextView else {
                return
            }
            // set SwiftUI-Binding
            parent.text = nsTextView.string
        }
        
        // Pass SwiftUI UndoManager to NSTextView
        func undoManager(for view: NSTextView) -> UndoManager? {
            parent.undoManger
        }

        // feel free to implement more delegate methods...
        
    }
    
}

#else // iOS
struct UIScrollableTextViewRepresentable: UIViewRepresentable {
    typealias Representable = Self
    
    // Hook this binding up with the parent View
    @Binding var text: String
    var fontName: String
    var fontSize: Double
    var lineLimit: Int?
    var textPadding: EdgeInsets
    
    private var uiInsets: UIEdgeInsets {
        UIEdgeInsets(
            top: textPadding.top,
            left: textPadding.leading,
            bottom: textPadding.bottom,
            right: textPadding.trailing
        )
    }
    
    // Get the UndoManager
    @Environment(\.undoManager) var undoManger
    
    // create an NSTextView
    func makeUIView(context: Context) -> UITextView {
        
        let textView = UITextView()
        
        // use SwiftUI Coordinator as the delegate
        textView.delegate = context.coordinator
        
        // set backgroundColor to clear (=> clear Background)
        // use .background-modifier later with SwiftUI-View
        textView.backgroundColor = .clear
        textView.isOpaque = false
        textView.textContainer.lineBreakMode = .byTruncatingTail
        
        textView.font = UIFont(name: fontName, size: CGFloat(fontSize))
        
        return textView
    }
    
    func updateUIView(_ textView: UITextView, context: Context) {
        let ranges = textView.selectedRange
        
        textView.font = UIFont(name: fontName, size: CGFloat(fontSize))
        textView.adjustsFontForContentSizeCategory = true
        
        textView.textContainer.maximumNumberOfLines = lineLimit ?? 0
        
        // set textView string from SwiftUI-Binding
        textView.text = text
        
        textView.selectedRange = ranges
        
        let needsDoneButton = UIDevice.current.userInterfaceIdiom == .phone
        if lineLimit == 1 {
            textView.returnKeyType = .done
        } else if needsDoneButton {
            context.coordinator.setupDoneButton(on: textView)
        }
        
        textView.textContainerInset = uiInsets
    }
    
    // Create Coordinator for this View
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Declare nested Coordinator class which conforms to UITextViewDelegate
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: Representable // store reference to parent
        private var singleLineMode: Bool { parent.lineLimit == 1 }
        
        weak private var textView: UITextView?
        
        init(_ textEditor: Representable) {
            self.parent = textEditor
        }
        
        func setupDoneButton(on textView: UITextView) {
            let bar = UIToolbar()
            let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(hideKeyboard))
            bar.items = [done]
            bar.sizeToFit()
            textView.inputAccessoryView = bar
            
            self.textView = textView
        }
        
        @objc func hideKeyboard(_ sender: UIBarButtonItem, _ event: UIEvent) {
            guard let textView else { return }
            
            if textView.canResignFirstResponder {
                textView.resignFirstResponder()
            }
        }
        
        // delegate method to retrieve changed text
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text ?? ""
        }
        
        // Pass SwiftUI UndoManager to NSTextView
        func undoManager(for view: UITextView) -> UndoManager? {
            parent.undoManger
        }

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if singleLineMode {
                if text == "\n" {
                    textView.resignFirstResponder()
                    return false
                }

                if text.contains("\n") {
                    return false
                }
            }
            
            return true
        }
    }
    
}

#endif
