import Foundation
import AnnotatedSentence
import WordNet
import MorphologicalAnalysis

public class SentenceAutoSemantic{
    
    /**
     * The method should set the senses of all words, for which there is only one possible sense.
     - Parameters:
        - sentence: The sentence for which word sense disambiguation will be determined automatically.
     */
    public func autoLabelSingleSemantics(sentence: AnnotatedSentence) -> Bool{return true}
    
    /// The method constructs all possible senses for the word at position index in the given sentence. The method checks
    /// the previous two words and the current word; the previous, current and next word, current and the next
    /// two words to add three word multiword sense (that occurs in the Turkish wordnet) to the result list. The
    /// method then check the previous word and current word; current word and the next word to add a two word multiword
    /// sense to the result list. Lastly, the method adds all possible senses of the current word to the result list.
    /// - Parameters:
    ///   - wordNet: Turkish wordnet
    ///   - fsm: Turkish morphological analyzer
    ///   - sentence: Sentence to be semantically disambiguated.
    ///   - index: Position of the word to be disambiguated.
    /// - Returns: All possible senses for the word at position index in the given sentence.
    public func getCandidateSynSets(wordNet: WordNet, fsm: FsmMorphologicalAnalyzer, sentence: AnnotatedSentence, index: Int) -> [SynSet]{
        var twoPrevious : AnnotatedWord? = nil
        var previous : AnnotatedWord? = nil
        var twoNext : AnnotatedWord? = nil
        var next : AnnotatedWord? = nil
        var synSets : [SynSet] = []
        let current = sentence.getWord(index: index) as! AnnotatedWord
        if index > 1 {
            twoPrevious = sentence.getWord(index: index - 2) as? AnnotatedWord
        }
        if index > 0 {
            previous = sentence.getWord(index: index - 1) as? AnnotatedWord
        }
        if index != sentence.wordCount() - 1 {
            next = sentence.getWord(index: index + 1) as? AnnotatedWord
        }
        if (index < sentence.wordCount() - 2){
            twoNext = sentence.getWord(index: index + 2) as? AnnotatedWord
        }
        synSets = wordNet.constructSynSets(word: current.getParse()!.getWord().getName(),
                                           parse: current.getParse()!, metaParse: current.getMetamorphicParse()!, fsm: fsm)
        if twoPrevious != nil && twoPrevious!.getParse() != nil && previous!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: twoPrevious!.getParse()!, morphologicalParse2: previous!.getParse()!, morphologicalParse3: current.getParse()!,
                                                                     metaParse1: twoPrevious!.getMetamorphicParse()!, metaParse2: previous!.getMetamorphicParse()!, metaParse3: current.getMetamorphicParse()!, fsm: fsm))
        }
        if previous != nil && previous!.getParse() != nil && next != nil && next!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current.getParse()!, morphologicalParse3: next!.getParse()!,
                                                                     metaParse1: previous!.getMetamorphicParse()!, metaParse2: current.getMetamorphicParse()!, metaParse3: next!.getMetamorphicParse()!, fsm: fsm))
        }
        if next != nil && next!.getParse() != nil && twoNext != nil && twoNext!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: current.getParse()!, morphologicalParse2: next!.getParse()!, morphologicalParse3: twoNext!.getParse()!,
                                                                     metaParse1: current.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, metaParse3: twoNext!.getMetamorphicParse()!, fsm: fsm))
        }
        if previous != nil && previous!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: previous!.getParse()!, morphologicalParse2: current.getParse()!,
                                                                     metaParse1: previous!.getMetamorphicParse()!, metaParse2: current.getMetamorphicParse()!, fsm: fsm))
        }
        if next != nil && next!.getParse() != nil {
            synSets.append(contentsOf: wordNet.constructIdiomSynSets(morphologicalParse1: current.getParse()!, morphologicalParse2: next!.getParse()!,
                                                                     metaParse1: current.getMetamorphicParse()!, metaParse2: next!.getMetamorphicParse()!, fsm: fsm))
        }
        return synSets
    }
    
    /// The method tries to semantic annotate as many words in the sentence as possible.
    /// - Parameter sentence: Sentence to be semantically disambiguated.
    public func autoSemantic(sentence: AnnotatedSentence){
        if autoLabelSingleSemantics(sentence: sentence){
        }
    }
}
