
namespace Ensembles.Models {
    public enum StylePartType {
        INTRO_1,
        INTRO_2,
        INTRO_3,
        BREAK,
        VARIATION_A,
        VARIATION_B,
        VARIATION_C,
        VARIATION_D,
        FILL_A,
        FILL_B,
        FILL_C,
        FILL_D,
        ENDING_1,
        ENDING_2,
        ENDING_3,
        EOS
    }

    public struct StylePart {
        public uint time_stamp;
        public StylePartType style_part_type;
    }

    public struct StylePartBounds {
        public int start;
        public int end;
    }
}
