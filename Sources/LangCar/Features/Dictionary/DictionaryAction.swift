import Foundation

enum DictionaryAction {
    case onAppear
    case searchTextChanged(String)
    case wordsLoaded([Word])
}
