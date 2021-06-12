namespace Ensembles.Core { 
    public class StyleAnalyser {
        public int analyze_style (string mid_file) {
            return style_analyser_analyze (mid_file);
        }
    }
}

extern int style_analyser_analyze (string mid_file);