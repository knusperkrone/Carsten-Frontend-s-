// cross-platfrom constants
const GENERATE_SEED = 5555;
const SHUFFLE_SEED = 1234;

// cross-platfrom results
const EXPECTED_GENERATED =
    'AAAAAAAAAAAAAAAAAACCCCCCCCCCCCCCCCEEFFFFFFFFFFFFFFGGGGGGGGGGGGGGGGGGHHHHHHHHHHIIIIIIIIIIIIIIIIIIJJJJJJJJLLLLLLLLLLLLLLMMMMMMMMMMNNNNOOOOOOOO';
const EXPECTED_SHUFFLED_SHUFFLER =
    'MIGEAOFCJGHLIAJGCAMICGJALIHOFMIACLGFCGHANOIFICJGMALOAIHGLCGALCIFMJHOIAHFGCLMFNGCLAICOMGLJNIFAHCAIGMLFLIAGCFHMGIFAOJLIHCAFGLEGFMIACHICGFAJOLN';

const EXPECTED_SHUFFLED_MANAGER =
    'AAOGFCLIHJAGNFMCILCLIAFGOICAFMHGALCJIFGHMACIGFLOINGAJCNMCAGHFILGCFAILCJIGHLMAOFIAGCOEOFGMJCLAIHELGIFMAGCNLIHJHILGMAFOALIHGJMCFOGAICJCLIAFGMH';

const EXPECTED_RANDS = [
  168436389,
  393334820,
  -694630088,
  171330600,
  1047929591,
  283907397,
  -1181869949,
  -1827189325,
  -1276504689,
  1662722334,
  -478906420,
  2105910257,
  -1232976125,
  -167556922,
  -1083395424,
  1296860842,
  -650568128,
  -570839267,
  1202697727,
  -1526886165,
  -1225431911,
  770370901,
  -625284969,
  1224804138,
  -1062438110,
  2034581428,
  753750581,
  669113261,
  -706604737,
  684866199,
  1502299768,
  1512772907
];

const INTEGRATION_TRACKS = '''
[
  {
    "origQueueIndex": 0,
    "durationMs": 3600,
    "isPrio": false,
    "queueIndex": 0,
    "title": "Beaches",
    "artist": "Warhaus",
    "album": "We Fucked a Flame into Being",
    "coverUrl": "https://i.scdn.co/image/ab67616d0000b2730d92b487656f1a784367ec8a"
  },
  {
    "origQueueIndex": 1,
    "durationMs": 3600,
    "isPrio": false,
    "queueIndex": 1,
    "title": "Nein - Prod. 2Rvr3Beatz",
    "artist": "Yung Hurn",
    "album": "In Memory of Yung Hurn - Classic Compilation",
    "coverUrl": "https://i.scdn.co/image/ab67616d0000b2733148235f9a339cf5be372060"
  },
  {
    "origQueueIndex": 2,
    "durationMs": 3600,
    "isPrio": false,
    "queueIndex": 2,
    "title": "Aftermath",
    "artist": "Hundreds",
    "album": "Aftermath",
    "coverUrl": "https://i.scdn.co/image/ab67616d0000b2737d005103ab2e2855db3bbbfd"
  },
  {
    "origQueueIndex": 3,
    "durationMs": 3600,
    "isPrio": false,
    "queueIndex": 3,
    "title": "3WW",
    "artist": "alt-J",
    "album": "RELAXER",
    "coverUrl": "https://i.scdn.co/image/ab67616d0000b273a244cd3c636e0759e20d758a"
  }
] 
''';
