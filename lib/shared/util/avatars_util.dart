class AvatarsUtil {
  static String getAvatarPathByLetter(String gender, String letter) {
    switch (letter.toUpperCase()) {
      case 'A': return 'images/letters/$gender/A.png';
      case 'B': return 'images/letters/$gender/B.png';
      case 'C': return 'images/letters/$gender/C.png';
      case 'D': return 'images/letters/$gender/D.png';
      case 'E': return 'images/letters/$gender/E.png';
      case 'F': return 'images/letters/$gender/F.png';
      case 'G': return 'images/letters/$gender/G.png';
      case 'H': return 'images/letters/$gender/H.png';
      case 'I': return 'images/letters/$gender/I.png';
      case 'J': return 'images/letters/$gender/J.png';
      case 'K': return 'images/letters/$gender/K.png';
      case 'L': return 'images/letters/$gender/L.png';
      case 'M': return 'images/letters/$gender/M.png';
      case 'N': return 'images/letters/$gender/N.png';
      case 'O': return 'images/letters/$gender/O.png';
      case 'P': return 'images/letters/$gender/P.png';
      case 'Q': return 'images/letters/$gender/Q.png';
      case 'R': return 'images/letters/$gender/R.png';
      case 'S': return 'images/letters/$gender/S.png';
      case 'T': return 'images/letters/$gender/T.png';
      case 'U': return 'images/letters/$gender/U.png';
      case 'V': return 'images/letters/$gender/V.png';
      case 'W': return 'images/letters/$gender/W.png';
      case 'X': return 'images/letters/$gender/X.png';
      case 'Y': return 'images/letters/$gender/Y.png';
      case 'Z': return 'images/letters/$gender/Z.png';
      case 'Ł': return 'images/letters/$gender/Ł.png';
      case 'Ż': return 'images/letters/$gender/Ż.png';
      default : return 'images/letters/$gender/unknown_letter.png';
    }
  }
}
