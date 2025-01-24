#[starknet::contract]
mod DeWordle {
    use dewordle::interfaces::{IDeWordle, PlayerStat, DailyPlayerStat};

    use starknet::{ContractAddress};

    use starknet::storage::{
        StoragePointerReadAccess, StoragePointerWriteAccess, StoragePathEntry, Map, Vec,
        MutableVecTrait, VecTrait
    };

    use dewordle::constants::LetterStates::{CORRECT, PRESENT, ABSENT};

    #[storage]
    struct Storage {
        word_of_the_day: ByteArray, //TODO: hash word
        letters_in_word: Vec<felt252>, //TODO: hash letters
        word_len: u8,
        player_stat: Map<ContractAddress, PlayerStat>,
        daily_player_stat: Map<ContractAddress, DailyPlayerStat>, // TODO: track day
    }

    #[abi(embed_v0)]
    impl DeWordleImpl of IDeWordle<ContractState> {
        fn set_daily_word(ref self: ContractState, word: ByteArray) {
            let word_len = word.len();
            let mut i = 0;

            while (i < word_len) {
                self.letters_in_word.append().write(word[i].into());
                i += 1;
            };
            self.word_of_the_day.write(word);
            self.word_len.write(word_len.try_into().unwrap());
        }

        fn get_daily_word(self: @ContractState) -> ByteArray {
            self.word_of_the_day.read()
        }

        //TODO
        // fn get_player_daily_stat(self: @ContractState, player: ContractAddress) ->
        // DailyPlayerStat {}

        // TODO
        fn play(ref self: ContractState) {}

        // TODO
        fn submit_guess(ref self: ContractState, guessed_word: ByteArray) {}

        // TODO
        fn is_correct_word(ref self: ContractState, guessed_word: ByteArray) -> bool {
            true
        }

        // TODO
        fn compare_word(ref self: ContractState, guessed_word: ByteArray) -> Span<u8> {
            let guessed_word_len = guessed_word.len();
            let word = self.get_daily_word();
            let mut i = 0;
            let mut word_states = array![];

            while (i < guessed_word_len) {
                let mut j = 0;
                if (guessed_word[i] == word[i]) {
                    word_states.append(CORRECT);
                } else {
                    let prev_word_states = word_states.clone();
                    while (j < guessed_word_len) {
                        if (guessed_word[i] == word[j]) {
                            word_states.append(PRESENT);
                            j = guessed_word_len;
                        }
                        j += 1;
                    };
                    if (prev_word_states.len() == word_states.len()) {
                        word_states.append(ABSENT);
                    }
                }
                i += 1;
            };

            word_states.span()
        }
    }
}
