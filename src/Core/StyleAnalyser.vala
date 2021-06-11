namespace Ensembles.Core { 
    public class StyleAnalyser {
        public void analyze_style (string mid_file) {
            style_analyser_analyze (mid_file);
        }
    }
}

extern void style_analyser_analyze (string mid_file);